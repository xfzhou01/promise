
#include "kernel/log.h"
#include "promise/AbcCommands.h"
#include "promise/Invariants.h"
#include "promise/ModelCheckingResult.h"
#include "promise/RTLIL/EncodingOptimization.h"
#include "promise/RTLIL/EquipInvariants.h"
#include "promise/RTLIL/RTLILUtils.h"
#include "promise/ShellUtils.h"
#include "promise/Timer.h"
#include "promise/VcdParser.h"
#include "promise/VerilatorUtils.h"

#include "kernel/rtlil.h"
#include "kernel/yosys.h"

#include "SynthesisFlow.h"
#include <Eigen/src/Core/Matrix.h>
#include <iostream>
#include <tuple>
#include <chrono>

std::vector<Wire *> getRegOutputs(RTLIL::Module *m) {
  // collect all FF outputs
  // The logic below attempts to get all bits driven by the Q output of a clock
  // std::set<RTLIL::SigBit> clockedBits;
  std::vector<RTLIL::Wire *> regOuts;
  for (auto *cell : m->cells()) {
    // traverse all cells under the module
    // TODO: filter more unhandled FF types
    assert(!cell->type.in("$dff") && "Unhandled cell type that is a FF");
    if (cell->type.in("$_DFF_P_")) {
      // if cell is a dff
      log("  Found DFF-type cell: %s of type %s\n", log_id(cell),
          log_id(cell->type));

      // FF output
      auto q = cell->getPort("\\Q");
      std::set<RTLIL::SigBit> outputset = q.to_sigbit_set();
      for (auto b : q.to_sigbit_set()) {
        // push back the wires
        regOuts.push_back(b.wire);
      }
    }
  }
  return regOuts;
}

// Compressing the unique rows from a vector of matrices into one matrix
Eigen::MatrixXi getUniqueRows(const vector<Eigen::MatrixXi> &matrices) {

  struct VectorCompare {
    bool operator()(const vector<int> &a, const vector<int> &b) const {
      return a < b;
    }
  };

  std::set<vector<int>, VectorCompare> uniqueRows;
  for (const auto &mat : matrices) {
    for (int i = 0; i < mat.rows(); ++i) {
      vector<int> row(mat.cols());
      for (int j = 0; j < mat.cols(); ++j) {
        row[j] = mat(i, j);
      }
      uniqueRows.insert(row);
    }
  }

  int numRows = uniqueRows.size();
  int numCols = uniqueRows.empty() ? 0 : uniqueRows.begin()->size();

  Eigen::MatrixXi result(numRows, numCols);
  int i = 0;
  for (const auto &row : uniqueRows) {
    for (int j = 0; j < numCols; ++j) {
      result(i, j) = row[j];
    }
    ++i;
  }
  return result;
}

// Attempt to prove the invariant and return the model checking result (which
// contains the analyzed counterexample data if the property failed).
ModelCheckingResult
verifyInvariant(const SynthesisFlowConfig &config, RTLIL::Module *m,
                const std::vector<LinearInvariant> &invariants) {

  RTLIL::Design *design = new RTLIL::Design;

  // Clone the design
  RTLIL::Module *cloned = m->clone();

  design->add(cloned);

  // Equip the module with an invariant and make it an PO. The goal of the model
  // checker is to prove that it is 1 in all reachable states.
  instrumentInvariants(cloned, invariants,
                       /* trimOriginalOutputs = */ true,
                       /* separateInvariants = */ false);

  auto miterVerilog = config.getCurrentProofDir() / "to_verify.v";
  run_pass("write_verilog " + miterVerilog.string(), design);

  auto miterBlif = config.getCurrentProofDir() / "to_verify.blif";
  run_pass("techmap; write_blif " + miterBlif.string(), design);

  auto pdrLogFile = config.getCurrentProofDir() / "pdr.log";

// #define USING_ABC_PDR
#ifdef USING_ABC_PDR
  runAbcPdrProof(miterBlif, pdrLogFile);
  ModelCheckingResult result =
      ModelCheckingResult::parseAbcLogFile(m, pdrLogFile);
#else
  runrIC3PdrProof(miterBlif, pdrLogFile);
  ModelCheckingResult result =
      ModelCheckingResult::parserIC3LogFile(m, pdrLogFile);
#endif

  delete design;
  return result;
}

void applyCombinationalOptimization(const SynthesisFlowConfig &config,
                                    RTLIL::Module *m) {
  // init a new design
  RTLIL::Design *design = new RTLIL::Design;

  // Clone the module
  RTLIL::Module *cloned = m->clone();
  
  // add cloned module to the design
  design->add(cloned);
  
  // initial blif path
  // after techmap (~)
  auto initialBlif = config.getSynthResultDir() / "initial.blif";
  
  // syn opt, do techmap & write blif
  run_pass("techmap; write_blif " + initialBlif.string(), design);
  
  // after opt path
  auto combinationalBaseline =
      config.getSynthResultDir() / "combinational.blif";
  
  // run opt from initial blif to combinational baseline
  runAbcCombOptimization(initialBlif, combinationalBaseline);
}

// Assuming that the conjunction of the invariants is proven, use scorr in ABC
// with invariants to optimize the design
void applyScorrOptimization(const SynthesisFlowConfig &config, RTLIL::Module *m,
                            const std::vector<LinearInvariant> &invariants) {
  
  for (auto &inv : invariants) {
    /* code */
  }
  

  RTLIL::Design *design = new RTLIL::Design;

  // Clone the design
  RTLIL::Module *cloned = m->clone();

  design->add(cloned);

  // Instrument the invariants, without trimming the original outputs
  instrumentInvariants(cloned, invariants,
                       /* trimOriginalOutputs = */ false,
                       /* separateInvariants = */ false);

  auto miterVerilog = config.getSynthResultDir() / "design_invariants.v";
  run_pass("write_verilog " + miterVerilog.string(), design);

  auto miterBlif = config.getSynthResultDir() / "design_invariants.blif";
  run_pass("techmap; write_blif " + miterBlif.string(), design);

  auto optimizedBlif =
      config.getSynthResultDir() / "design_invariants_scorred.blif";

  unsigned numPOBits = 0;
  int maxPortId = -1;
  for (Wire *identifier : cloned->wires()) {
    if (identifier->port_output) {
      numPOBits += identifier->width;
      maxPortId =
          maxPortId < identifier->port_id ? identifier->port_id : maxPortId;
    }
  }
  // for (auto cell : )
  auto *propertyPin = cloned->wire(RTLIL::escape_id("property_pin"));
  assert(propertyPin->port_id == maxPortId);

  runAbcScorrOptimization(miterBlif, optimizedBlif, /* inductionDepth */ 10,
                          /* withInvariants */ true, numPOBits);
}

void applyEncodingOptimization(const SynthesisFlowConfig &config,
                               RTLIL::Module *m,
                               const std::vector<LinearInvariant> &invariants) {
  RTLIL::Design *design = new RTLIL::Design;

  // Clone the design
  RTLIL::Module *cloned = m->clone();

  design->add(cloned);

  auto originalBlif = config.getSynthResultDir() / "original.blif";
  run_pass("techmap; write_blif " + originalBlif.string(), design);

  run_pass("clean", design);

  auto outputDebug = config.getSynthResultDir() / "design_debug.v";
  run_pass("write_verilog " + outputDebug.string(), design);

  applyEncodingOptimizationUsingInvariants(cloned, invariants);
  run_pass("clean", design);

  auto outputVerilog = config.getSynthResultDir() / "design_encoding.v";
  run_pass("write_verilog " + outputVerilog.string(), design);

  auto outputBlif = config.getSynthResultDir() / "design_encoding.blif";
  run_pass("techmap; write_blif " + outputBlif.string(), design);

  runSequentialEquivalenceChecking(originalBlif, outputBlif, 3600);
}

// This is the "suggest" and "guarnatee" step
bool synthesisFlow(SynthesisFlowConfig config, RTLIL::Design *design,
                   const std::string &topName) {
  // escape id -> translate the identifier name in RTLIL
  // input a string and output a string
  // example:
  //  main -> \\main
  //  $special -> $special
  //  \\main -> \\main
  RTLIL::Module *m = design->module(RTLIL::escape_id(topName));

  // run yosys pass claean
  run_pass("clean", design);
  
  // print cell information
  // example: Cell $abc$118135$auto$blifparse.cc:396:parse_blif$118136 Type $_NOT_ Port A Wire ap_enable_reg_pp0_iter1
  for (auto *cell : m->cells().to_vector()) {
    for (auto [portIdentifier, sigSpec] : cell->connections()) {

      if (sigSpec.is_wire()) {
        std::cerr << "Cell " << log_id(cell->name) << " Type "
                  << log_id(cell->type) << " Port " << log_id(portIdentifier)
                  << " Wire " << log_id(sigSpec.as_wire()->name) << "\n";
      }
    }
  }
  // m is the top module
  applyCombinationalOptimization(config, m);

  // get all reg output wires
  auto regOuts = getRegOutputs(m);

  // [STEP]: retrieve single-bit register output signals.
  // get single bit name
  std::vector<RTLIL::IdString> singleBitRegOuts;
  for (auto *sig : regOuts) {
    if (sig->width == 1) {
      singleBitRegOuts.push_back(sig->name);
    }
  }

  for (auto sig_id : singleBitRegOuts) {
    std::cerr << "reg output signal: " << sig_id.str() << std::endl;
  }

  // Flattened verilog design: after removing procs and mapping all FFs to
  // simple FFs
  auto flattenedVerilog = config.getOutputDir() / VERILOG_FLATTENED;
  run_pass("write_verilog " + flattenedVerilog.string(), design);

  // [STEP]: Simulate the design:
  std::vector<Eigen::MatrixXi> simData;
  for (unsigned i = 0; i < 4; i++, config.newSimIteration()) {
    // Object directory for SUGGEST
    auto verilatorSimObjDir =
        config.getCurrentSimDir() / VERILATOR_OBJ_DIR_NAME;
    auto testbenchFile = config.getCurrentSimDir() / VERILATOR_TB_NAME;
    auto vcdFile = config.getCurrentSimDir() / SIM_WAVEFORM;

    std::cerr << "verilatorSimObjDir: " << verilatorSimObjDir << std::endl;
    std::cerr << "testbenchFile:      " << testbenchFile << std::endl;
    std::cerr << "vcdFile:            " << vcdFile <<  std::endl;

    // Compile the design into a simulation model:
    // - pathToVerilatorTb: the name of the Verilator TB file in cpp
    // - module: the RTLIL module to create the testbench for
    // - sim 2500 cycles
    // - vcd file name
    // - seed for random
    createRandomTestBench(testbenchFile, m, 2500, vcdFile, i);

    // rebuild the Verilator model
    // - verilatorSimObjDir: the directory to put the compiled model
    // - flattenedVerilog: the Verilog file to compile
    // - testbenchFile: the testbench file to use
    // - topName: the name of the top module
    buildVerilatorModel(verilatorSimObjDir, {flattenedVerilog}, testbenchFile,
                        topName);

    // Launch the binary:
    // launch simulation
    std::stringstream simCmd;
    simCmd << (verilatorSimObjDir / ("V" + topName));
    shell(simCmd.str());

    Eigen::MatrixXi signalMatrix =
        vcdToSignalMatrix(m, vcdFile, singleBitRegOuts);
    simData.push_back(signalMatrix);
  }

  auto signalMatrix = getUniqueRows(simData);

  // [STEP]: Suggest invariants from the signalMatrix:
  std::vector<LinearInvariant> linearInvariants =
      inferLinearEqualities(m, signalMatrix, singleBitRegOuts);

  std::vector<LinearInvariant> linearInequalities =
      inferLinearInequalitiesViaConflictGraph(m, signalMatrix,
                                              singleBitRegOuts);

  for (const auto &inv : linearInvariants) {
    std::cerr << "Suggested invariant (initial): " << inv.dump() << std::endl;
  }

  for (const auto &inv : linearInequalities) {
    std::cerr << "Suggested inequality (initial): " << inv.dump() << std::endl;
  }

  std::copy(linearInequalities.begin(), linearInequalities.end(),
            std::back_inserter(linearInvariants));

  // [STEP]: Guarantee the correctness of the generated invariants
  // This step will run the model checker to verify that the invariants hold
  ModelCheckingResult modelCheckingResult =
      verifyInvariant(config, m, linearInvariants);
  config.newProofIteration();

  // Print the model checking result
  if (modelCheckingResult.status == ModelCheckingResult::SAFE) {
    std::cerr << "Model checking result: SAFE" << std::endl;
  } else if (modelCheckingResult.status == ModelCheckingResult::UNSAFE) {
    std::cerr << "Model checking result: UNSAFE" << std::endl;
    std::cerr << "Counterexample states: " << modelCheckingResult.numCexStates
              << std::endl;
    for (const auto &pair : modelCheckingResult.inputValues) {
      std::cerr << "Signal: " << pair.first.str() << " Values: ";
      for (const auto &value : pair.second) {
        std::cerr << value << " ";
      }
      std::cerr << std::endl;
    }
  } else {
    std::cerr << "Model checking result: UNKNOWN" << std::endl;
  }

  // [STEP]: Iterate between "suggest" and "guarantee" phases to prove the
  // conjunction of invariants:
  // iterate until the model checker returns SAFE
  while (modelCheckingResult.status == ModelCheckingResult::UNSAFE) {
    auto cexTbFile = config.getCurrentProofDir() / VERILATOR_TB_NAME;
    auto vcdFile = config.getCurrentProofDir() / SIM_WAVEFORM;
    auto verilatorObjDir = config.getCurrentProofDir() / VERILATOR_OBJ_DIR_NAME;
    auto testbenchFile = config.getCurrentProofDir() / VERILATOR_TB_NAME;

    // [STEP]: Collect the states from the latest model checking result
    createCexTestBench(cexTbFile, m, modelCheckingResult, vcdFile);

    buildVerilatorModel(verilatorObjDir, {flattenedVerilog}, testbenchFile, topName);    // Launch the binary:
    std::stringstream simCmd;
    simCmd << (verilatorObjDir / ("V" + topName));

    auto start_time = std::chrono::high_resolution_clock::now();
    shell(simCmd.str());
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);
    std::cerr << "Simulation command completed in " << duration.count() << " ms" << std::endl;

    // Retrieve the signal matrix from CEX
    auto cexMatrix = vcdToSignalMatrix(m, vcdFile, singleBitRegOuts);
    signalMatrix = getUniqueRows({signalMatrix, cexMatrix});

    // [STEP]: Suggest invariants from the signalMatrix:
    linearInvariants = inferLinearEqualities(m, signalMatrix, singleBitRegOuts);
    linearInequalities = inferLinearInequalitiesViaConflictGraph(
        m, signalMatrix, singleBitRegOuts);

    for (const auto &inv : linearInvariants) {
      std::cerr << "Suggested invariant (iteration " << config.getProofIteration()
                << "): " << inv.dump() << std::endl;
    }

    for (const auto &inv : linearInequalities) {
      std::cerr << "Suggested inequality (iteration " << config.getProofIteration()
                << "): " << inv.dump() << std::endl;
    }
    std::cerr << "Iteration: " << config.getProofIteration() << std::endl;
    std::cerr << "Total invariants: "
              << linearInvariants.size() + linearInequalities.size() << std::endl;
    std::cerr << "Total linear inequalities: "
              << linearInequalities.size() << std::endl;
    
    std::copy(linearInequalities.begin(), linearInequalities.end(),
              std::back_inserter(linearInvariants));

    modelCheckingResult = verifyInvariant(config, m, linearInvariants);

    config.newProofIteration();
    if (modelCheckingResult.status == ModelCheckingResult::SAFE) {
      std::cerr << "Model checking result: SAFE" << std::endl;
    } else if (modelCheckingResult.status == ModelCheckingResult::UNSAFE) {
      std::cerr << "Model checking result: UNSAFE" << std::endl;
      std::cerr << "Counterexample states: " << modelCheckingResult.numCexStates
                << std::endl;
      for (const auto &pair : modelCheckingResult.inputValues) {
        std::cerr << "Signal: " << pair.first.str() << " Values: ";
        for (const auto &value : pair.second) {
          std::cerr << value << " ";
        }
        std::cerr << std::endl;
      }
    } else {
      std::cerr << "Model checking result: UNKNOWN" << std::endl;
    }
  }

  assert(modelCheckingResult.status == ModelCheckingResult::SAFE);
  applyScorrOptimization(config, m, linearInvariants);

  applyEncodingOptimization(config, m, linearInvariants);
  return true;
}
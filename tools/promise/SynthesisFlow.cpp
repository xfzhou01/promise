
#include "kernel/log.h"
#include "promise/AbcCommands.h"
#include "promise/Invariants.h"
#include "promise/ModelCheckingResult.h"
#include "promise/RTLIL/EncodingOptimization.h"
#include "promise/RTLIL/EquipInvariants.h"
#include "promise/RTLIL/RTLILUtils.h"
#include "promise/ShellUtils.h"
#include "promise/Simulation/VcdParser.h"
#include "promise/Simulation/VerilatorUtils.h"
#include "promise/Timer.h"

#include "kernel/rtlil.h"
#include "kernel/yosys.h"

#include "SynthesisFlow.h"
#include <Eigen/src/Core/Matrix.h>
#include <iostream>
#include <tuple>
#define USING_ABC_PDR

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
ModelCheckingResult verifyInvariant(const SynthesisFlowConfig &config,
                                    RTLIL::Module *m,
                                    const std::vector<Invariant> &invariants) {

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
  run_pass("opt_clean; write_verilog " + miterVerilog.string(), design);

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

void flowComb(const SynthesisFlowConfig &config, RTLIL::Module *m) {
  RTLIL::Design *design = new RTLIL::Design;

  // Clone the design
  RTLIL::Module *cloned = m->clone();

  design->add(cloned);

  auto initialBlif = config.getSynthResultDir() / "initial.blif";
  run_pass("techmap; write_blif " + initialBlif.string(), design);

  auto combinationalBaseline =
      config.getSynthResultDir() / "combinational.blif";

  runAbcCombOptimization(initialBlif, combinationalBaseline);
}

// Assuming that the conjunction of the invariants is proven, use scorr in ABC
// with invariants to optimize the design
void flowScorrInvar(const SynthesisFlowConfig &config, RTLIL::Module *m,
                    const std::vector<Invariant> &invariants) {

  RTLIL::Design *design = new RTLIL::Design;

  // Clone the design
  RTLIL::Module *cloned = m->clone();

  design->add(cloned);

  // Instrument the invariants, without trimming the original outputs
  instrumentInvariants(cloned, invariants,
                       /* trimOriginalOutputs = */ false,
                       /* separateInvariants = */ false);

  auto miterVerilog = config.getSynthResultDir() / "design_invariants.v";
  std::cout << "[INFO] miterVerilog = " << miterVerilog.string() << std::endl;
  run_pass("write_verilog " + miterVerilog.string(), design);

  auto miterBlif = config.getSynthResultDir() / "design_invariants.blif";
  std::cout << "[INFO] miterBlif = " << miterBlif.string() << std::endl;
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
  std::cout << "[INFO] optimizedBlif = " << optimizedBlif.string() << std::endl;
  runAbcScorrOptimization(miterBlif, optimizedBlif, /* inductionDepth */ 10,
                          /* withInvariants */ true, numPOBits);
}

void flowEncoding(const SynthesisFlowConfig &config, RTLIL::Module *m,
                  const std::vector<Invariant> &invariants) {
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

Eigen::MatrixXi
runRandomSimulation(RTLIL::Module *m, const std::string &topName,
                    SynthesisFlowConfig &config,
                    const std::filesystem::path &flattenedVerilog,
                    const std::vector<RTLIL::IdString> &signalList) {
  // [STEP]: Simulate the design:
  std::vector<Eigen::MatrixXi> simData;
  for (unsigned i = 0; i < 4; i++, config.newSimIteration()) {
    // Object directory for SUGGEST
    auto verilatorSimObjDir =
        config.getCurrentSimDir() / VERILATOR_OBJ_DIR_NAME;
    auto testbenchFile = config.getCurrentSimDir() / VERILATOR_TB_NAME;
    auto vcdFile = config.getCurrentSimDir() / SIM_WAVEFORM;

    // Compile the design into a simulation model:
    createRandomTestBench(testbenchFile, m, 2500, vcdFile, i);

    buildVerilatorModel(verilatorSimObjDir, {flattenedVerilog}, testbenchFile,
                        topName);

    // Launch the binary:
    std::stringstream simCmd;
    simCmd << (verilatorSimObjDir / ("V" + topName));
    shell(simCmd.str());

    Eigen::MatrixXi signalMatrix = vcdToSignalMatrix(m, vcdFile, signalList);
    simData.push_back(signalMatrix);
  }

  return getUniqueRows(simData);
}

std::vector<Invariant> inferLinearInvariantsFromSimulation(
    RTLIL::Module *m, SynthesisFlowConfig &config, Eigen::MatrixXi signalMatrix,
    const std::vector<RTLIL::IdString> &signalList,
    const std::filesystem::path &flattenedVerilog, const std::string &topName) {
  std::cerr << "[INFO] signal matrix content before update:\n";
  std::cerr << signalMatrix << "\n";
  // [STEP]: Suggest invariants from the signalMatrix:
  std::vector<Invariant> linearInvariants =
      inferLinearEqualities(m, signalMatrix, signalList);
  std::cerr << "[INFO] Suggested invariants:\n";
  for (const auto &inv : linearInvariants) {
    std::cerr << "[INFO] invariant: " << inv.toString() << "\n";
  }
  std::vector<Invariant> linearInequalities =
      inferLinearInequalitiesViaConflictGraph(m, signalMatrix, signalList);

  std::copy(linearInequalities.begin(), linearInequalities.end(),
            std::back_inserter(linearInvariants));
  
  // print the suggested invariants
  std::cerr << "[INFO] Suggested invariants:\n";
  for (const auto &inv : linearInvariants) {
    std::cerr << "[INFO] invariant: " << inv.toString() << "\n";
  }

  // [STEP]: Guarantee the correctness of the generated invariants
  ModelCheckingResult modelCheckingResult =
      verifyInvariant(config, m, linearInvariants);
  config.newProofIteration();

  // [STEP]: Iterate between "suggest" and "guarantee" phases to prove the
  // conjunction of invariants:
  while (modelCheckingResult.status == ModelCheckingResult::UNSAFE) {
    auto cexTbFile = config.getCurrentProofDir() / VERILATOR_TB_NAME;
    auto vcdFile = config.getCurrentProofDir() / SIM_WAVEFORM;
    auto verilatorObjDir = config.getCurrentProofDir() / VERILATOR_OBJ_DIR_NAME;
    auto testbenchFile = config.getCurrentProofDir() / VERILATOR_TB_NAME;

    // [STEP]: Collect the states from the latest model checking result
    createCexTestBench(cexTbFile, m, modelCheckingResult, vcdFile);
    buildVerilatorModel(verilatorObjDir, {flattenedVerilog}, testbenchFile,
                        topName);

    // Launch the binary:
    std::stringstream simCmd;
    simCmd << (verilatorObjDir / ("V" + topName));
    shell(simCmd.str());
    // std::cerr << "[INFO] signal matrix content before update:\n";
    // std::cerr << signalMatrix << "\n";
    // Retrieve the signal matrix from CEX
    std::cerr << "[INFO] Parsing CEX file vcd: " << vcdFile << "\n";
    auto cexMatrix = vcdToSignalMatrix(m, vcdFile, signalList);
    // print cex matrix
    std::cerr << "[INFO] CEX matrix:\n";
    std::cerr << cexMatrix << "\n";
    std::cerr << "[INFO] CEX matrix size: " << cexMatrix.rows() << "x"
              << cexMatrix.cols() << "\n";
    std::cerr << "[INFO] signal matrix size before update: " << signalMatrix.rows()
              << "x" << signalMatrix.cols() << "\n";
    signalMatrix = getUniqueRows({signalMatrix, cexMatrix});
    std::cerr << "[INFO] Updated signal matrix size: " << signalMatrix.rows()
              << "x" << signalMatrix.cols() << "\n";
    // [STEP]: Suggest invariants from the signalMatrix:
    linearInvariants = inferLinearEqualities(m, signalMatrix, signalList);
    linearInequalities =
        inferLinearInequalitiesViaConflictGraph(m, signalMatrix, signalList);
    std::copy(linearInequalities.begin(), linearInequalities.end(),
              std::back_inserter(linearInvariants));

    std::cerr << "[INFO] Suggested invariants:\n";
    for (const auto &inv : linearInvariants) {
      std::cerr << "[INFO] invariant: " << inv.toString() << "\n";
    }

    modelCheckingResult = verifyInvariant(config, m, linearInvariants);

    config.newProofIteration();
    std::cerr << "[INFO] iteration " << config.getProofIteration() << std::endl;
  }
  std::cerr << "[INFO] Exiting the CEGAR loop" << std::endl;;
  assert(modelCheckingResult.status == ModelCheckingResult::SAFE);

  return linearInvariants;
}

// This is the "suggest" and "guarnatee" step
bool synthesisFlow(SynthesisFlowConfig config, RTLIL::Design *design,
                   const std::string &topName) {

  RTLIL::Module *m = design->module(RTLIL::escape_id(topName));

  run_pass("clean", design);

  flowComb(config, m);

  auto regOuts = getRegOutputs(m);

  // [STEP]: retrieve single-bit register output signals.
  std::vector<RTLIL::IdString> singleBitRegOuts;
  for (auto *sig : regOuts) {
    if (sig->width == 1) {
      singleBitRegOuts.push_back(sig->name);
    }
  }

  auto flattenedVerilog = config.getOutputDir() / VERILOG_FLATTENED;
  run_pass("write_verilog " + flattenedVerilog.string(), design);
  std::cerr << "[INFO] singleBitRegOuts" << std::endl;
  for (const auto &sig : singleBitRegOuts) {
    std::cerr << "[INFO] " << sig.str() << std::endl;
  }
  auto signalMatrix = runRandomSimulation(m, topName, config, flattenedVerilog,
                                          singleBitRegOuts);

  auto linearInvariants = inferLinearInvariantsFromSimulation(
      m, config, signalMatrix, singleBitRegOuts, flattenedVerilog, topName);

  std::cerr << "[INFO] List of proven invariants:\n";
  for (const auto &inv : linearInvariants) {
    std::cerr << "[INFO] invariant: " << inv.toString() << "\n";
  }

  flowScorrInvar(config, m, linearInvariants);

  flowEncoding(config, m, linearInvariants);
  return true;
}
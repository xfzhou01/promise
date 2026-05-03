#include <iostream>
#include <ostream>
#include <stdexcept>

#include "promise/ModelCheckingResult.h"
#include "promise/RTLIL/RTLILUtils.h"
#include "promise/ShellUtils.h"
#include "promise/Simulation/VerilatorUtils.h"
#include "promise/StringUtils.h"

#include "kernel/log.h"
#include "kernel/rtlil.h"

using namespace Yosys;

// Create a Verilator testbench feed with random inputs
void createRandomTestBench(const std::filesystem::path &pathToVerilatorTb,
                           RTLIL::Module *module, unsigned simCycles,
                           const std::string &vcdFileName, unsigned seed) {

  std::ofstream os(pathToVerilatorTb);

  if (!os.is_open()) {
    throw std::runtime_error("failed to open file: " +
                             pathToVerilatorTb.string());
  }

  // log_id(): Getting a clean name without leading backslash or trailing space.
  std::string topName = log_id(module->name);

  // Assumption: the design has a clock and a reset input
  std::string clk;
  std::string rst;

  for (auto *input : module->wires()) {
    if (input->port_input) {
      std::string sigName = input->name.c_str();
      if (sigName.find("clk") != std::string::npos) {
        clk = log_id(sigName);
      }
      if (sigName.find("rst") != std::string::npos) {
        rst = log_id(sigName);
      }
    }
  }

  // NOTE: We assume that the clock input is called "clk"
  if (clk.empty())
    throw std::runtime_error(
        "Cannot find the clk signal \"clk\" in the circuit!");

  // NOTE: We assume that the module reset is called "rst"
  if (rst.empty())
    throw std::runtime_error(
        "Cannot find the rst signal \"rst\" in the circuit!");

  os << "#include \"V" << topName << ".h\"\n";
  os << "#include \"verilated.h\"\n";
  os << "#include \"verilated_vcd_c.h\"\n";
  os << "#include <cstdlib>\n";
  os << "#include <ctime>\n\n";
  os << "#include <random>\n\n";

  os << "int main (int argc, char** argv, char**env) {\n";
  os << "  std::mt19937 randomEngine(" << seed << ");\n";
  os << "  Verilated::commandArgs(argc, argv);\n";
  os << "  V" << topName << "* top = new V" << topName << ";\n";
  os << "  VerilatedVcdC * tfp = new VerilatedVcdC;\n";
  os << "  Verilated::traceEverOn(true);\n";
  os << "  top->trace(tfp, 99);\n";
  os << "  tfp->open(\"" << vcdFileName << "\");\n";
  os << "  std::srand(std::time(nullptr));\n";
  os << "  top->" << rst << " = 1;\n";
  os << "  top->" << clk << " = 0;\n";
  os << "  top->eval();\n";
  os << "  tfp->dump(0);\n";
  os << "  top->" << rst << " = 0;\n";
  os << "  for (size_t i = 1; i < " << 2 * simCycles << "; ++i) {\n";
  os << "    top->" << clk << " = !top->" << clk << ";\n";
  /// IMPORTANT: in verilator, the deltas happen together with the clock edge
  /// will not captured by risedge(clk). Therefore, if the FFs are triggered by
  /// rising edge, we need to update the values at the falling edge.
  os << "    // Update signal on the negedge\n";
  os << "    if (!top->" << clk << "){\n";
  for (auto *inputSig : module->wires()) {
    if (inputSig->port_input && log_id(inputSig) != clk &&
        log_id(inputSig) != rst) {
      size_t mask = (1 << inputSig->width) - 1;
      os << "      top->" << log_id(inputSig) << " = randomEngine() & 0x"
         << std::hex << mask << ";\n";
    }
  }
  os << "    }\n";

  os << "    top->eval();\n";
  os << "    tfp->dump(i);\n";
  os << "  }\n";
  os << "  tfp->close();\n";
  os << "  delete top;\n";
  os << "  return 0;\n";
  os << "}\n";
}

void createCexTestBench(const std::filesystem::path &pathToVerilatorTb,
                        RTLIL::Module *module, ModelCheckingResult cex,
                        const std::string &vcdFileName) {
  // print cex content if unsafe
  if (cex.status == ModelCheckingResult::UNSAFE) {
    std::cerr << "[INFO] CEX status: UNSAFE\n";
    std::cerr << "[INFO] CEX input values:\n";
    std::cerr << "[INFO] Number of CEX states: " << cex.numCexStates << "\n";
    for (const auto &pair : cex.inputValues) {
      std::cerr << "Signal: " << pair.first.str() << " Values: ";
      for (const auto &val : pair.second) {
        std::cerr << val << " ";
      }
      std::cerr << "\n";
    }
  } else {
    std::cerr << "[INFO] CEX status: " << (cex.status == ModelCheckingResult::SAFE ? "SAFE" : "UNKNOWN") << "\n";
  }
    
  std::ofstream os(pathToVerilatorTb);

  if (!os.is_open()) {
    throw std::runtime_error("failed to open file: " +
                             pathToVerilatorTb.string());
  }

  // log_id(): Getting a clean name without leading backslash or trailing space.
  std::string topName = log_id(module->name);

  // Assumption: the design has a clock and a reset input
  std::string clk;
  std::string rst;

  for (auto *input : module->wires()) {
    if (input->port_input) {
      std::string sigName = input->name.c_str();
      if (sigName.find("clk") != std::string::npos) {
        clk = log_id(sigName);
      }
    }
  }

  auto inputWires = getSortedInput(module);

  if (clk.empty())
    throw std::runtime_error(
        "Cannot find the clk signal \"clk\" in the circuit!");

  os << "#include \"V" << topName << ".h\"\n";
  os << "#include \"verilated.h\"\n";
  os << "#include \"verilated_vcd_c.h\"\n";
  os << "#include <cstdlib>\n";
  os << "#include <ctime>\n\n";

  os << "int main (int argc, char** argv, char**env) {\n";
  os << "  Verilated::commandArgs(argc, argv);\n";
  os << "  V" << topName << "* top = new V" << topName << ";\n";
  os << "  VerilatedVcdC * tfp = new VerilatedVcdC;\n";
  os << "  Verilated::traceEverOn(true);\n";
  os << "  top->trace(tfp, 99);\n";
  os << "  tfp->open(\"" << vcdFileName << "\");\n";
  os << "  std::srand(std::time(nullptr));\n";
  // os << "  top->" << rst << " = 1;\n";
  os << "  top->" << clk << " = 1;\n";
  os << "  top->eval();\n";
  os << "  tfp->dump(0);\n";

  assert(cex.numCexStates > 0);

  for (unsigned i = 0; i < cex.numCexStates; i += 1) {
    os << "  // <===== Cex of state =====>" << i << "\n";
    os << "  // Falling clock edge:\n";
    /// IMPORTANT: in verilator, the deltas happen together with the clock edges
    /// will not captured by posedge(clk). Therefore, if the FFs are triggered
    /// by posedge edge, we need to update the values at the falling edge.
    os << "  top->" << clk << " = !top->" << clk << ";\n";
    for (const auto &inputSig : inputWires) {
      assert(inputSig->port_input);
      if (log_id(inputSig) != clk) {
        assert(i < cex.inputValues.at(inputSig->name).size());
        long long mask = ((long long)1 << inputSig->width) - 1;
        os << "  // decimal of width: " << inputSig->width << "\n";
        os << "  // decimal of mask: " << mask << "\n";
        os << "  top->" << log_id(inputSig) << " = "
           << cex.inputValues.at(inputSig->name)[i] << " & 0x" << std::hex
           << mask << ";\n"
           << std::dec;
      }
    }
    os << "  top->eval();\n";
    os << "  // Dumping state " << i << "\n";
    os << "  tfp->dump(" << 2 * i + 1 << ");\n";
    os << "  // Rising clock edge:\n";
    os << "  top->" << clk << " = !top->" << clk << ";\n";
    os << "  top->eval();\n";
    os << "  tfp->dump(" << 2 * i + 2 << ");\n";
  }
  os << "  tfp->close();\n";
  os << "  delete top;\n";
  os << "  return 0;\n";
  os << "}\n";
}

void runVerilatorLinting(const std::vector<std::string> &verilogSrcs,
                         const std::string &topName) {

  std::stringstream verilatorCmd;
  verilatorCmd << std::filesystem::path(PROMISE_BINARIES_DIR) / "verilator";
    verilatorCmd
      << " --lint-only "
      << " --Wall"
      << " --Wno-UNUSED"
      << " --Wno-WIDTHTRUNC"
      << " --Wno-WIDTHEXPAND"
      << " --Wno-WIDTHXZEXPAND"
      << " --Wno-DECLFILENAME"
      << " --Wno-UNDRIVEN"
      << " --Wno-EOFNEWLINE"
      << " --Wno-BLKSEQ"
      << " --Wno-PINCONNECTEMPTY"
      << " --Wno-PROCASSINIT"
      << " --Wno-PINMISSING"
      << " --Wno-GENUNNAMED"
      << " --Wno-UNOPTFLAT"
      << " --Wno-LATCH"
      << " --Wno-COMBDLY"
      << " --Wno-SYMRSVDWORD"
      << " --Wno-CASEINCOMPLETE"
      << " --Wno-ASCRANGE"
      << " --top-module "
      << topName;
  for (const auto &src : verilogSrcs) {
    verilatorCmd << " " << src;
  }

  auto [code, stdout] = shell(verilatorCmd.str());

  if (code != 0) {
    std::cerr << "Error: Verilator failed to lint the design.\n" << stdout;
    throw std::runtime_error("Verilator linting failed");
  }
}

void buildVerilatorModel(const std::filesystem::path &objDir,
                         const std::vector<std::filesystem::path> &verilogSrcs,
                         const std::filesystem::path &testbench,
                         const std::string &topName) {

  // Generate the CPP simulation model
  std::stringstream verilatorCmd;
  verilatorCmd << std::filesystem::path(PROMISE_BINARIES_DIR) / "verilator";
  verilatorCmd << " --trace -Mdir " << objDir;
  verilatorCmd << " --cc ";
  for (const auto &src : verilogSrcs) {
    verilatorCmd << " " << src;
  }
  verilatorCmd << " --exe " << testbench;

  // Some internal signals in xls might begin with an underscore.
  // NOTE: be aware that we also need `--coverage-underscore` at some point
  verilatorCmd << " --trace-underscore";
  verilatorCmd << " --Wno-UNOPTFLAT";
  verilatorCmd << " --top-module " << topName;
  auto [code, stdout] = shell(verilatorCmd.str());

  if (code != 0) {
    std::cerr << "Error: Verilator failed to compile the design.\n" << stdout;
    throw std::runtime_error("Verilator compilation failed");
  }

  // Compile the CPP simulation model
  std::stringstream makeCmd;
  makeCmd << "make -C " << objDir;
  makeCmd << " -f V" << topName + ".mk";
  makeCmd << " V" << topName;

  shell(makeCmd.str());
}

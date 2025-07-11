#include <iostream>
#include <ostream>
#include <stdexcept>
#include <chrono>

#include "promise/ModelCheckingResult.h"
#include "promise/RTLIL/RTLILUtils.h"
#include "promise/ShellUtils.h"
#include "promise/StringUtils.h"
#include "promise/VerilatorUtils.h"

#include "kernel/log.h"
#include "kernel/rtlil.h"

using namespace Yosys;

// Create a Verilator testbench feed with random inputs
void createRandomTestBench(const std::filesystem::path &pathToVerilatorTb,
                           RTLIL::Module *module, unsigned simCycles,
                           const std::string &vcdFileName, unsigned seed) {
  // Open the file to write the testbench
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

  // Initialize the random number generator with the given seed
  os << "  std::mt19937 randomEngine(" << seed << ");\n";
  os << "  Verilated::commandArgs(argc, argv);\n";
  os << "  V" << topName << "* top = new V" << topName << ";\n";
  os << "  VerilatedVcdC * tfp = new VerilatedVcdC;\n";
  os << "  Verilated::traceEverOn(true);\n";

  // Create a trace file for waveform output, 99 is the verbosity level
  os << "  top->trace(tfp, 99);\n";
  os << "  tfp->open(\"" << vcdFileName << "\");\n";
  os << "  std::srand(std::time(nullptr));\n";

  // Set the initial state of the clock and reset signals
  // NOTE: The reset signal is set to 1 initially, then set to 0
  os << "  top->" << rst << " = 1;\n";
  os << "  top->" << clk << " = 0;\n";

  // Evaluate the initial state of the design
  // This is necessary to initialize the design before starting the simulation
  os << "  top->eval();\n";
  // Dump the initial state to the VCD file
  os << "  tfp->dump(0);\n";

  // Start the simulation loop
  os << "  for (size_t i = 1; i < " << 2 * simCycles << "; ++i) {\n";
  // Toggle the clock signal to simulate a clock cycle
  os << "    top->" << clk << " = !top->" << clk << ";\n";
  // Set the reset signal to 0 after the first clock cycle
  os << "    if (i==2) top->" << rst << " = 0;\n";
  // Randomly set the input signals
  os << "    if (top->" << clk << "){\n";
  for (auto *inputSig : module->wires()) {
    if (inputSig->port_input && log_id(inputSig) != clk &&
        log_id(inputSig) != rst) {
      size_t mask = (1 << inputSig->width) - 1;
      os << "      top->" << log_id(inputSig) << " = randomEngine() & 0x"
         << std::hex << mask << ";\n";
    }
  }
  os << "    }\n";
  // Evaluate the design at the rising clock edge
  os << "    top->eval();\n";
  // Dump the current state to the VCD file
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

  // Open the file to write the testbench
  os << "  tfp->open(\"" << vcdFileName << "\");\n";
  os << "  std::srand(std::time(nullptr));\n";
  // os << "  top->" << rst << " = 1;\n"; // NO NEED FOR RESET
  // Set the initial state of the clock signal
  os << "  top->" << clk << " = 0;\n";
  os << "  top->eval();\n";
  os << "  // Dumping the initial state (state 0)\n";
  os << "  tfp->dump(0);\n";

  assert(cex.numCexStates > 0);

  for (unsigned i = 0; i < cex.numCexStates; ++i) {
    os << "  // Cex of state " << i + 1 << "\n";
    os << "  top->" << clk << " = !top->" << clk << ";\n";
    for (const auto &inputSig : inputWires) {
      assert(inputSig->port_input);
      if (log_id(inputSig) != clk) {
        size_t mask = (1 << inputSig->width) - 1;
        os << "  top->" << log_id(inputSig) << " = "
           << cex.inputValues.at(inputSig->name)[i] << " & 0x" << std::hex
           << mask << ";\n"
           << std::dec;
      }
    }
    // Evaluate the rising clock edge
    os << "  top->eval();\n";
    os << "  // Dumping state " << i + 1 << "\n";
    os << "  tfp->dump(" << i + 1 << ");\n";
    os << "  top->" << clk << " = !top->" << clk << ";\n";
    // Evaluate the falling clock edge
    os << "  top->eval();\n";
  }
  os << "  tfp->close();\n";
  os << "  delete top;\n";
  os << "  return 0;\n";
  os << "}\n";
}

void runVerilatorLinting(const std::vector<std::string> &verilogSrcs,
                         const std::string &topName) {
  // verilator command form
  // static lint checking of verilog code in veriloator
  // use system command
  std::stringstream verilatorCmd;
  verilatorCmd << std::filesystem::path(PROMISE_BINARIES_DIR) / "verilator";
  // verilatorCmd
  //     << " --lint-only -Wall --Wno-UNUSED --Wno-WIDTHTRUNC --top-module "
  //     << topName;
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

  auto start_time = std::chrono::high_resolution_clock::now();

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
  verilatorCmd << " --top-module " << topName;
  auto [code, stdout_str] = shell(verilatorCmd.str());

  if (code != 0) {
    std::cerr << "Error: Verilator failed to compile the design.\n" << stdout_str;
    throw std::runtime_error("Verilator compilation failed");
  }

  // Compile the CPP simulation model
  std::stringstream makeCmd;
  makeCmd << "make -C " << objDir;
  makeCmd << " -f V" << topName + ".mk";
  makeCmd << " V" << topName;

  // do compile
  shell(makeCmd.str());

  auto end_time = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);
  std::cerr << "buildVerilatorModel completed in " << duration.count() << " ms" << std::endl;
}

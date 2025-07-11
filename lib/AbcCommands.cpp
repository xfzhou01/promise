
#include <cstddef>
#include <filesystem>
#include <fstream>
#include <future>
#include <iostream>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <sys/wait.h>
#include <vector>

#include "promise/AbcCommands.h"
#include "promise/ShellUtils.h"
#include "promise/StringUtils.h"
#include "promise/Timer.h"

void runAbcPdrProof(const std::string &filename,
                    const std::string &logFileName) {
  Abc_Start();

  Abc_Frame_t *pAbc;

  pAbc = Abc_FrameGetGlobalFrame();

  runAbcCommand(pAbc, "read_blif " + filename);
  runAbcCommand(pAbc, "st");

  {
    Timer t("pdr");
    std::string cmd = "pdr -L " + logFileName;
    Cmd_CommandExecute(pAbc, cmd.c_str());
  }

  Abc_Stop();
}

void runrIC3PdrProof(const std::string &blifFileName,
                     const std::string &logFileName) {
  Abc_Start();
  Abc_Frame_t *pAbc;
  pAbc = Abc_FrameGetGlobalFrame();
  runAbcCommand(pAbc, "read_blif " + blifFileName);
  runAbcCommand(pAbc, "st");
  runAbcCommand(pAbc, "write_aiger /tmp/model.aig");
  Abc_Stop();

  std::stringstream cmd;
  cmd << std::filesystem::path(PROMISE_BINARIES_DIR) / "rIC3"
      << " -e ic3 --witness /tmp/model.aig";
  auto [retCode, output] = shell(cmd.str());

  if (retCode != 10 && retCode != 20) {
    throw std::runtime_error("Error - rIC3 exited unexpectedly!");
  }

  std::ofstream f(logFileName);
  if (!f.is_open()) {
    throw std::runtime_error("Cannot open file " + logFileName);
  }

  f << output;
}

void runAbcCombOptimization(const std::string &filename,
                            const std::string &outputFileName) {
  Abc_Start();
  Abc_Frame_t *pAbc;
  // get abc pointer
  pAbc = Abc_FrameGetGlobalFrame();

  runAbcCommand(pAbc, "read_blif " + filename + "");
  runAbcCommand(pAbc, "st");
  runAbcCommand(pAbc, "if -K 6");
  runAbcCommand(pAbc, "ps");
  runAbcCommand(pAbc, "write_blif " + outputFileName);

  Abc_Stop();
}

void runAbcScorrOptimization(const std::string &filename,
                             const std::string &outputFileName,
                             unsigned inductionDepth, bool withInvariants,
                             unsigned numPOs) {
  Abc_Start();

  if (inductionDepth == 0)
    throw std::runtime_error("Induction depth cannot be 0!");

  Abc_Frame_t *pAbc;

  pAbc = Abc_FrameGetGlobalFrame();

  runAbcCommand(pAbc, ("read_blif " + filename));
  runAbcCommand(pAbc, ("st"));

  if (withInvariants) {
    runAbcCommand(pAbc, "constr -N 1");
  }

  std::stringstream cmd;
  cmd << "scorr";
  if (withInvariants)
    cmd << " -c";
  cmd << " -F " << inductionDepth;
  runAbcCommand(pAbc, cmd.str());

  if (withInvariants) {
    std::stringstream cmd;
    runAbcCommand(pAbc, "constr -r");
    runAbcCommand(pAbc, "zeropo -N " + std::to_string(numPOs - 1));
    runAbcCommand(pAbc, "removepo -N " + std::to_string(numPOs - 1));
  }

  runAbcCommand(pAbc, "if -K 6; ps");
  runAbcCommand(pAbc, "write_blif " + outputFileName);

  Abc_Stop();
}

void runSequentialEquivalenceChecking(const std::string &source,
                                      const std::string &target,
                                      unsigned timeout) {

  Abc_Start();

  Abc_Frame_t *pAbc;

  pAbc = Abc_FrameGetGlobalFrame();

  runAbcCommand(pAbc, "miter " + source + " " + target);

  runAbcCommand(pAbc, "dprove -T " + std::to_string(timeout));

  Abc_Stop();
}

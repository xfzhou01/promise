#pragma once
#include <array>
#include <cstddef>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <sys/wait.h>
#include <utility>
#include <vector>

#include "promise/StringUtils.h"

namespace fs = std::filesystem;

// Create directory recursively if it doesn't exist
inline bool mkdir(const fs::path &dirPath) {
  try {
    if (!fs::exists(dirPath)) {
      return fs::create_directories(dirPath); // like `mkdir -p`
    }
    return fs::is_directory(dirPath);
  } catch (const fs::filesystem_error &e) {
    std::cerr << "Filesystem error: " << e.what() << std::endl;
    return false;
  }
}

// Run a shell command and return return code and stdout
inline std::pair<int, std::string> shell(const std::string &cmd) {
  // stack the final message: result
  std::string result;
  std::array<char, 128> buffer;

  std::cerr << "[Shell] Command: \"" << cmd << "\""
            << "\n";
  // create subprocess and communicate
  FILE *pipe = popen(cmd.c_str(), "r");
  if (!pipe)
    throw std::runtime_error("Cannot open the pipe for reading!");

  // read 128 byte data from pipe
  while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
    result += buffer.data();
  }
  
  // get return code
  int returnCode = pclose(pipe);

  // return code / 256 = exit code
  int exitCode = WEXITSTATUS(returnCode); // gets actual exit code

  return std::make_pair(exitCode, result);
}
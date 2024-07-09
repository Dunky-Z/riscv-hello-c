#include <stdio.h>

static int test_brev(int value) {
  int result;

  //     func7      rs2       rs1    func3      rd      opcode
  // 31-------25|24-----20|19-----15|14---12|11-----7|6-------0|
  // |  1111111 |   rs2   |   rs1   |  101  |   rd   | 0001011 | R-tyep

  // R type: .insn r opcode, func3, func7, rd, rs1, rs2
  asm volatile(".insn r 0xB, 0x5, 0x7F, %0, %1, x0"
               : "=r"(result)
               : "r"(value));
  return result;
}

int main() {

  // 10010001101000101011001111000
  // 00011110011010100010110001001
  int origin = 0x12345678;
  int expected = 0x3CD4589;
  int ret = 0;

  ret = test_brev(origin);
  printf("ret = %x\n", ret);

  if (ret == expected) {
    printf("test pass\n");
  } else {
    printf("test fail\n");
  }

  while (1) {
  }
}

#include <stdio.h>

static int test_brev(int value) {
  int result;

  // R type: .insn r opcode, func3, func7, rd, rs1, rs2
  asm volatile(".insn r 0xB, 0x5, 0x7F, %0, %1, x0"
               : "=r"(result)
               : "r"(value));
  return result;
}

int main() {
  int origin = 0x12345678;
  int expected = 0x1E6A2C48; // 假设这是位反转后的结果
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

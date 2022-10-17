#![program is unsafe]
#
# Gadget should never execute regularly, speculation leaks data.
.text
    r2 = *(u64 *)(r1 + 0)
    r8 = 1
    r9 = 1
    # wrong: r8==0 ^ r9==0 <=>
    #  <=> (r8==0 & r9!=0 | r8!=0 & r9==0)
    #  <=> gadget always reached
    #  <=> safe
    # possible: r8!=0 & r9!=0
    if r8 == 0 goto Gadget
    # r8!=0
    if r9 != 0 goto End
    # r8!=0 & r9==0
    #
    # Safe, if always reached.
Gadget:
    # r8==0 | r9==0
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

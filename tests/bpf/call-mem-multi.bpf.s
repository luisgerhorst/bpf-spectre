#![program is unsafe]
#
# Branch might be taken, then speculation leaks data.
# That's because a call can change arbitrary memory locations, invalidating the
# invariant that otherwise ensures the branch is never taken.
.text
    r6 = var ll
    r7 = 0
    *(u64 *)(r6 + 0) = r7
    *(u64 *)(r6 + 8) = r7
    r1 = r6
    call 1
    r8 = *(u64 *)(r6 + 0)
    r9 = *(u64 *)(r6 + 8)
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
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

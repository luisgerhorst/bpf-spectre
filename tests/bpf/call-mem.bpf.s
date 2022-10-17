#![program is unsafe]
.text
    r6 = var ll
    r7 = 0
    *(u64 *)(r6 + 8) = r7
    r1 = r6
    call 1
    # var may have changed because it was passed to the call, r8 can be != 0 now
    r8 = *(u64 *)(r6 + 8)
    # May seem as if r8==7 is guaranteed here. Then branch is never taken.
    #
    # Gadget, unless never taken:
    if r8 > 0 goto End
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

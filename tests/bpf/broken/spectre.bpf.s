#![program is unsafe]
.text
    r2 = *(u64 *)(r1 + 0)
    r3 = *(u64 *)(r1 + 8)
    if r2 >= r3 goto End
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

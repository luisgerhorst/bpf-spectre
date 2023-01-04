#![program is safe]
.text
    # Read 8 bytes from ctx pointer.
    r2 = *(u64 *)(r1 + 0)
    r3 = r2
    # Branch is never taken.
    if r2 != r3 goto End
    # Data is always exposed.
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

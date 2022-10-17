# [program is unsafe]
#
# Branch might be taken, then speculation leaks data.
# That's because multiple calls might return different values.
.text
    call 1
    r6 = r0
    call 1
    # Gadget unless call is never taken:
    if r0 != r6 goto End
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

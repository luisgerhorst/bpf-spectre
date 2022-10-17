# [program is unsafe]
#
# Gadget should never execute regularly, speculation leaks data.
.text
    r6 = 0
    *(u64 *)(r1 + 0) = r6
    r9 = *(u64 *)(r1 + 0)
    if r9 == 0 goto End
Gadget:
    r2 = *(u64 *)(r2 + 0)
    r2 *= 512
    r2 = *(u64 *)(r2 + 0)
End:
    r0 = 0
    exit

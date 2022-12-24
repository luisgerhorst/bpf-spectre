	.text
	.file	"sockfilter.bpf.c"
	.file	0 "/home/luis/Documents/desk/proj/spectector-bpf/spectector/tests/bpf/external-samples/libbpf-bootstrap/examples/c" "sockfilter.bpf.c" md5 0x8eaeef60e28156923ab9415698c3e2c5
	.file	1 "/usr/include/asm-generic" "int-ll64.h" md5 0xb810f270733e106319b67ef512c6246e
	.file	2 ".output/bpf" "bpf_helper_defs.h" md5 0xb1d735cb26930da0ef44cf6372b51e0b
	.file	3 "/usr/include/linux" "in.h" md5 0x9a7f04155c254fef1b7ada5eb82c984c
	.section	socket,"ax",@progbits
	.globl	socket_handler                  # -- Begin function socket_handler
	.p2align	3
	.type	socket_handler,@function
socket_handler:                         # @socket_handler
.Lfunc_begin0:
	.loc	0 33 0                          # sockfilter.bpf.c:33:0
	.cfi_sections .debug_frame
	.cfi_startproc
# %bb.0:
	#DEBUG_VALUE: socket_handler:skb <- $r1
	r6 = r1
.Ltmp0:
.Ltmp1:
	#DEBUG_VALUE: socket_handler:proto <- [DW_OP_plus_uconst 2, DW_OP_deref] $r10
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	#DEBUG_VALUE: socket_handler:skb <- $r6
	r3 = r10
.Ltmp2:
	.loc	0 0 0 is_stmt 0                 # sockfilter.bpf.c:0:0
.Ltmp3:
.Ltmp4:
	r3 += -6
	.loc	0 39 2 prologue_end is_stmt 1   # sockfilter.bpf.c:39:2
.Ltmp5:
	r2 = 12
	r4 = 2
	call 26
.Ltmp6:
	.loc	0 40 10                         # sockfilter.bpf.c:40:10
.Ltmp7:
	r1 = *(u16 *)(r10 - 6)
.Ltmp8:
.Ltmp9:
	#DEBUG_VALUE: socket_handler:proto <- $r1
	r2 = r1
	r2 = be16 r2
.Ltmp10:
.Ltmp11:
	#DEBUG_VALUE: socket_handler:proto <- $r2
	.loc	0 40 8 is_stmt 0                # sockfilter.bpf.c:40:8
.Ltmp12:
	*(u16 *)(r10 - 6) = r2
	r8 = 0
	.loc	0 41 6 is_stmt 1                # sockfilter.bpf.c:41:6
.Ltmp13:
	if r1 != 8 goto LBB0_6
.Ltmp14:
.Ltmp15:
# %bb.1:
	#DEBUG_VALUE: socket_handler:proto <- $r2
	#DEBUG_VALUE: socket_handler:skb <- $r6
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	#DEBUG_VALUE: ip_is_fragment:skb <- $r6
	#DEBUG_VALUE: ip_is_fragment:nhoff <- 14
	#DEBUG_VALUE: ip_is_fragment:frag_off <- [DW_OP_plus_uconst 6, DW_OP_deref] $r10
	.loc	0 0 6 is_stmt 0                 # sockfilter.bpf.c:0:6
	r3 = r10
.Ltmp16:
.Ltmp17:
.Ltmp18:
	r3 += -2
	.loc	0 26 2 is_stmt 1                # sockfilter.bpf.c:26:2
.Ltmp19:
	r1 = r6
	r2 = 20
.Ltmp20:
.Ltmp21:
	r4 = 2
	call 26
.Ltmp22:
	.loc	0 27 13                         # sockfilter.bpf.c:27:13
.Ltmp23:
	r1 = *(u16 *)(r10 - 2)
.Ltmp24:
.Ltmp25:
	#DEBUG_VALUE: ip_is_fragment:frag_off <- undef
	.loc	0 28 18                         # sockfilter.bpf.c:28:18
.Ltmp26:
	r1 &= 65343
.Ltmp27:
.Ltmp28:
	.loc	0 44 6                          # sockfilter.bpf.c:44:6
.Ltmp29:
	if r1 != 0 goto LBB0_6
.Ltmp30:
.Ltmp31:
# %bb.2:
	#DEBUG_VALUE: socket_handler:skb <- $r6
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	.loc	0 0 6 is_stmt 0                 # sockfilter.bpf.c:0:6
	r8 = 0
	.loc	0 48 6 is_stmt 1                # sockfilter.bpf.c:48:6
.Ltmp32:
	r1 = rb ll
	r2 = 24
	r3 = 0
	call 131
.Ltmp33:
	r7 = r0
.Ltmp34:
.Ltmp35:
	#DEBUG_VALUE: socket_handler:e <- $r7
	.loc	0 49 6                          # sockfilter.bpf.c:49:6
.Ltmp36:
	if r7 == 0 goto LBB0_6
.Ltmp37:
.Ltmp38:
# %bb.3:
	#DEBUG_VALUE: socket_handler:e <- $r7
	#DEBUG_VALUE: socket_handler:skb <- $r6
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	.loc	0 52 72                         # sockfilter.bpf.c:52:72
.Ltmp39:
	r3 = r7
	r3 += 12
	.loc	0 52 2 is_stmt 0                # sockfilter.bpf.c:52:2
.Ltmp40:
	r1 = r6
	r2 = 23
	r4 = 1
	call 26
.Ltmp41:
	.loc	0 54 9 is_stmt 1                # sockfilter.bpf.c:54:9
.Ltmp42:
.Ltmp43:
	r1 = *(u32 *)(r7 + 12)
.Ltmp44:
.Ltmp45:
	.loc	0 54 6 is_stmt 0                # sockfilter.bpf.c:54:6
.Ltmp46:
	if r1 == 47 goto LBB0_5
.Ltmp47:
.Ltmp48:
# %bb.4:
	#DEBUG_VALUE: socket_handler:e <- $r7
	#DEBUG_VALUE: socket_handler:skb <- $r6
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	.loc	0 55 3 is_stmt 1                # sockfilter.bpf.c:55:3
.Ltmp49:
	r1 = r6
	r2 = 26
	r3 = r7
	r4 = 4
	call 26
.Ltmp50:
	.loc	0 56 71                         # sockfilter.bpf.c:56:71
.Ltmp51:
	r3 = r7
	r3 += 4
	.loc	0 56 3 is_stmt 0                # sockfilter.bpf.c:56:3
.Ltmp52:
	r1 = r6
	r2 = 30
	r4 = 4
	call 26
.Ltmp53:
.Ltmp54:
LBB0_5:
	#DEBUG_VALUE: socket_handler:e <- $r7
	#DEBUG_VALUE: socket_handler:skb <- $r6
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	#DEBUG_VALUE: socket_handler:verlen <- [DW_OP_plus_uconst 5, DW_OP_deref] $r10
	.loc	0 0 3                           # sockfilter.bpf.c:0:3
	r3 = r10
.Ltmp55:
	r3 += -3
	.loc	0 59 2 is_stmt 1                # sockfilter.bpf.c:59:2
.Ltmp56:
	r1 = r6
	r2 = 14
	r4 = 1
	call 26
.Ltmp57:
	.loc	0 60 36                         # sockfilter.bpf.c:60:36
.Ltmp58:
	r2 = *(u8 *)(r10 - 3)
.Ltmp59:
.Ltmp60:
	#DEBUG_VALUE: socket_handler:verlen <- $r2
	.loc	0 60 50 is_stmt 0               # sockfilter.bpf.c:60:50
.Ltmp61:
	r2 <<= 2
.Ltmp62:
.Ltmp63:
	r2 &= 60
	.loc	0 60 32                         # sockfilter.bpf.c:60:32
.Ltmp64:
	r2 += 14
	.loc	0 60 62                         # sockfilter.bpf.c:60:62
.Ltmp65:
	r3 = r7
	r3 += 8
	.loc	0 60 2                          # sockfilter.bpf.c:60:2
.Ltmp66:
	r1 = r6
	r4 = 4
	call 26
.Ltmp67:
	.loc	0 61 21 is_stmt 1               # sockfilter.bpf.c:61:21
.Ltmp68:
	r1 = *(u32 *)(r6 + 4)
	.loc	0 61 14 is_stmt 0               # sockfilter.bpf.c:61:14
.Ltmp69:
	*(u32 *)(r7 + 16) = r1
	.loc	0 62 20 is_stmt 1               # sockfilter.bpf.c:62:20
.Ltmp70:
	r1 = *(u32 *)(r6 + 40)
	.loc	0 62 13 is_stmt 0               # sockfilter.bpf.c:62:13
.Ltmp71:
	#
    # Gadget for Spec. Type Confusion on Stack using SSB
	#
	# Program state:
	# r1: skb->ifindex
	# r6: ctx_ptr skb
	# r7: ringbuf_elem_ptr e
	# r10: frame pointer (fp)
	# fp-64: not initialized (type STACK_INVALID)
	#
	# Create Spec. Type Confusion:
	r4 = -16 # valid offset
    *(u64 *)(r10 - 16) = r4 # make valid
	if r1 == 0 goto UNKNOWN
	r4 = -8
    *(u64 *)(r10 - 8) = r4 # make valid
UNKNOWN:
	r3 = -64 # invalid offset
    r3 += r10
    r9 = r10 # fp alias for ssb
    *(u64 *)(r10 - 16) = r3
	# lfence added here
    *(u64 *)(r9 - 16) = r4 # ssb here
	# No lfence added here because stack slot was not STACK_INVALID.
	# To fix this vuln., a lfence should also be added when the slot contained a ptr.
    r8 = *(u64 *)(r10 - 16) # spec. invalid offset, arch. variable but valid offset
	r8 += r10
	# CATCH: Rejected because var. stack ptr arith. prohibited (masking not implemented) and const. arith (r4 == 8) would be optimized after ssb.
	r8 = *(u64 *)(r8 - 0) # spec. read of invalid stack slot
	#
	# Leak data to SMT-silbling using ADD port-contention, break KASLR.
	r8 &= 1  # choose bit to leak
	if r8 == 0 goto	NO_CONTENTION
	r0 += 1
	r0 += 1
	# <snip>, imagine many add-ops here
	r0 += 1
	r0 += 1
NO_CONTENTION:
END:
    #
	# Spec. Gadget End
	#
	*(u32 *)(r7 + 20) = r1
	.loc	0 63 2 is_stmt 1                # sockfilter.bpf.c:63:2
.Ltmp72:
	r1 = r7
	r2 = 0
	call 132
.Ltmp73:
	.loc	0 65 14                         # sockfilter.bpf.c:65:14
.Ltmp74:
	r8 = *(u32 *)(r6 + 0)
.Ltmp75:
.Ltmp76:
LBB0_6:
	#DEBUG_VALUE: socket_handler:skb <- $r6
	#DEBUG_VALUE: socket_handler:nhoff <- 14
	.loc	0 66 1                          # sockfilter.bpf.c:66:1
.Ltmp77:
	r0 = r8
	exit
.Ltmp78:
.Ltmp79:
.Lfunc_end0:
	.size	socket_handler, .Lfunc_end0-socket_handler
	.cfi_endproc
	.file	4 "../../libbpf/include/uapi/linux" "bpf.h" md5 0x19e7a278dd5e69adb087c419977e86e0
	.file	5 "/usr/include/linux" "types.h" md5 0x52ec79a38e49ac7d1dc9e146ba88a7b1
                                        # -- End function
	.type	LICENSE,@object                 # @LICENSE
	.section	license,"aw",@progbits
	.globl	LICENSE
LICENSE:
	.asciz	"Dual BSD/GPL"
	.size	LICENSE, 13

	.type	rb,@object                      # @rb
	.section	.maps,"aw",@progbits
	.globl	rb
	.p2align	3
rb:
	.zero	16
	.size	rb, 16

	.file	6 "." "sockfilter.h" md5 0x404c050a0a7b0cbf021a33d05c345ac9
	.section	.debug_loclists,"",@progbits
	.long	.Ldebug_list_header_end0-.Ldebug_list_header_start0 # Length
.Ldebug_list_header_start0:
	.short	5                               # Version
	.byte	8                               # Address size
	.byte	0                               # Segment selector size
	.long	5                               # Offset entry count
.Lloclists_table_base0:
	.long	.Ldebug_loc0-.Lloclists_table_base0
	.long	.Ldebug_loc1-.Lloclists_table_base0
	.long	.Ldebug_loc2-.Lloclists_table_base0
	.long	.Ldebug_loc3-.Lloclists_table_base0
	.long	.Ldebug_loc4-.Lloclists_table_base0
.Ldebug_loc0:
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Lfunc_begin0-.Lfunc_begin0    #   starting offset
	.uleb128 .Ltmp0-.Lfunc_begin0           #   ending offset
	.byte	1                               # Loc expr size
	.byte	81                              # DW_OP_reg1
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp0-.Lfunc_begin0           #   starting offset
	.uleb128 .Lfunc_end0-.Lfunc_begin0      #   ending offset
	.byte	1                               # Loc expr size
	.byte	86                              # DW_OP_reg6
	.byte	0                               # DW_LLE_end_of_list
.Ldebug_loc1:
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp0-.Lfunc_begin0           #   starting offset
	.uleb128 .Ltmp8-.Lfunc_begin0           #   ending offset
	.byte	2                               # Loc expr size
	.byte	122                             # DW_OP_breg10
	.byte	2                               # 2
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp8-.Lfunc_begin0           #   starting offset
	.uleb128 .Ltmp10-.Lfunc_begin0          #   ending offset
	.byte	1                               # Loc expr size
	.byte	81                              # DW_OP_reg1
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp10-.Lfunc_begin0          #   starting offset
	.uleb128 .Ltmp20-.Lfunc_begin0          #   ending offset
	.byte	1                               # Loc expr size
	.byte	82                              # DW_OP_reg2
	.byte	0                               # DW_LLE_end_of_list
.Ldebug_loc2:
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp14-.Lfunc_begin0          #   starting offset
	.uleb128 .Ltmp24-.Lfunc_begin0          #   ending offset
	.byte	2                               # Loc expr size
	.byte	122                             # DW_OP_breg10
	.byte	6                               # 6
	.byte	0                               # DW_LLE_end_of_list
.Ldebug_loc3:
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp34-.Lfunc_begin0          #   starting offset
	.uleb128 .Ltmp75-.Lfunc_begin0          #   ending offset
	.byte	1                               # Loc expr size
	.byte	87                              # DW_OP_reg7
	.byte	0                               # DW_LLE_end_of_list
.Ldebug_loc4:
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp53-.Lfunc_begin0          #   starting offset
	.uleb128 .Ltmp59-.Lfunc_begin0          #   ending offset
	.byte	2                               # Loc expr size
	.byte	122                             # DW_OP_breg10
	.byte	5                               # 5
	.byte	4                               # DW_LLE_offset_pair
	.uleb128 .Ltmp59-.Lfunc_begin0          #   starting offset
	.uleb128 .Ltmp62-.Lfunc_begin0          #   ending offset
	.byte	1                               # Loc expr size
	.byte	82                              # DW_OP_reg2
	.byte	0                               # DW_LLE_end_of_list
.Ldebug_list_header_end0:
	.section	.debug_abbrev,"",@progbits
	.byte	1                               # Abbreviation Code
	.byte	17                              # DW_TAG_compile_unit
	.byte	1                               # DW_CHILDREN_yes
	.byte	37                              # DW_AT_producer
	.byte	37                              # DW_FORM_strx1
	.byte	19                              # DW_AT_language
	.byte	5                               # DW_FORM_data2
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	114                             # DW_AT_str_offsets_base
	.byte	23                              # DW_FORM_sec_offset
	.byte	16                              # DW_AT_stmt_list
	.byte	23                              # DW_FORM_sec_offset
	.byte	27                              # DW_AT_comp_dir
	.byte	37                              # DW_FORM_strx1
	.byte	17                              # DW_AT_low_pc
	.byte	27                              # DW_FORM_addrx
	.byte	18                              # DW_AT_high_pc
	.byte	6                               # DW_FORM_data4
	.byte	115                             # DW_AT_addr_base
	.byte	23                              # DW_FORM_sec_offset
	.ascii	"\214\001"                      # DW_AT_loclists_base
	.byte	23                              # DW_FORM_sec_offset
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	2                               # Abbreviation Code
	.byte	52                              # DW_TAG_variable
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	63                              # DW_AT_external
	.byte	25                              # DW_FORM_flag_present
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	2                               # DW_AT_location
	.byte	24                              # DW_FORM_exprloc
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	3                               # Abbreviation Code
	.byte	1                               # DW_TAG_array_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	4                               # Abbreviation Code
	.byte	33                              # DW_TAG_subrange_type
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	55                              # DW_AT_count
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	5                               # Abbreviation Code
	.byte	36                              # DW_TAG_base_type
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	62                              # DW_AT_encoding
	.byte	11                              # DW_FORM_data1
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	6                               # Abbreviation Code
	.byte	36                              # DW_TAG_base_type
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	62                              # DW_AT_encoding
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	7                               # Abbreviation Code
	.byte	19                              # DW_TAG_structure_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	8                               # Abbreviation Code
	.byte	13                              # DW_TAG_member
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	56                              # DW_AT_data_member_location
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	9                               # Abbreviation Code
	.byte	15                              # DW_TAG_pointer_type
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	10                              # Abbreviation Code
	.byte	33                              # DW_TAG_subrange_type
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	55                              # DW_AT_count
	.byte	6                               # DW_FORM_data4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	11                              # Abbreviation Code
	.byte	52                              # DW_TAG_variable
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	12                              # Abbreviation Code
	.byte	21                              # DW_TAG_subroutine_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	39                              # DW_AT_prototyped
	.byte	25                              # DW_FORM_flag_present
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	13                              # Abbreviation Code
	.byte	5                               # DW_TAG_formal_parameter
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	14                              # Abbreviation Code
	.byte	38                              # DW_TAG_const_type
	.byte	0                               # DW_CHILDREN_no
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	15                              # Abbreviation Code
	.byte	22                              # DW_TAG_typedef
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	16                              # Abbreviation Code
	.byte	15                              # DW_TAG_pointer_type
	.byte	0                               # DW_CHILDREN_no
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	17                              # Abbreviation Code
	.byte	21                              # DW_TAG_subroutine_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	39                              # DW_AT_prototyped
	.byte	25                              # DW_FORM_flag_present
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	18                              # Abbreviation Code
	.byte	4                               # DW_TAG_enumeration_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	19                              # Abbreviation Code
	.byte	40                              # DW_TAG_enumerator
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	28                              # DW_AT_const_value
	.byte	15                              # DW_FORM_udata
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	20                              # Abbreviation Code
	.byte	46                              # DW_TAG_subprogram
	.byte	1                               # DW_CHILDREN_yes
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	39                              # DW_AT_prototyped
	.byte	25                              # DW_FORM_flag_present
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	32                              # DW_AT_inline
	.byte	33                              # DW_FORM_implicit_const
	.byte	1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	21                              # Abbreviation Code
	.byte	5                               # DW_TAG_formal_parameter
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	22                              # Abbreviation Code
	.byte	52                              # DW_TAG_variable
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	23                              # Abbreviation Code
	.byte	19                              # DW_TAG_structure_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	24                              # Abbreviation Code
	.byte	13                              # DW_TAG_member
	.byte	0                               # DW_CHILDREN_no
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.byte	56                              # DW_AT_data_member_location
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	25                              # Abbreviation Code
	.byte	13                              # DW_TAG_member
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.ascii	"\210\001"                      # DW_AT_alignment
	.byte	15                              # DW_FORM_udata
	.byte	56                              # DW_AT_data_member_location
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	26                              # Abbreviation Code
	.byte	23                              # DW_TAG_union_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.ascii	"\210\001"                      # DW_AT_alignment
	.byte	15                              # DW_FORM_udata
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	27                              # Abbreviation Code
	.byte	13                              # DW_TAG_member
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.byte	56                              # DW_AT_data_member_location
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	28                              # Abbreviation Code
	.byte	23                              # DW_TAG_union_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	29                              # Abbreviation Code
	.byte	19                              # DW_TAG_structure_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	5                               # DW_FORM_data2
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	30                              # Abbreviation Code
	.byte	46                              # DW_TAG_subprogram
	.byte	1                               # DW_CHILDREN_yes
	.byte	17                              # DW_AT_low_pc
	.byte	27                              # DW_FORM_addrx
	.byte	18                              # DW_AT_high_pc
	.byte	6                               # DW_FORM_data4
	.byte	64                              # DW_AT_frame_base
	.byte	24                              # DW_FORM_exprloc
	.byte	122                             # DW_AT_call_all_calls
	.byte	25                              # DW_FORM_flag_present
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	39                              # DW_AT_prototyped
	.byte	25                              # DW_FORM_flag_present
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	63                              # DW_AT_external
	.byte	25                              # DW_FORM_flag_present
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	31                              # Abbreviation Code
	.byte	5                               # DW_TAG_formal_parameter
	.byte	0                               # DW_CHILDREN_no
	.byte	2                               # DW_AT_location
	.byte	34                              # DW_FORM_loclistx
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	32                              # Abbreviation Code
	.byte	52                              # DW_TAG_variable
	.byte	0                               # DW_CHILDREN_no
	.byte	2                               # DW_AT_location
	.byte	34                              # DW_FORM_loclistx
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	33                              # Abbreviation Code
	.byte	52                              # DW_TAG_variable
	.byte	0                               # DW_CHILDREN_no
	.byte	28                              # DW_AT_const_value
	.byte	15                              # DW_FORM_udata
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	34                              # Abbreviation Code
	.byte	29                              # DW_TAG_inlined_subroutine
	.byte	1                               # DW_CHILDREN_yes
	.byte	49                              # DW_AT_abstract_origin
	.byte	19                              # DW_FORM_ref4
	.byte	17                              # DW_AT_low_pc
	.byte	27                              # DW_FORM_addrx
	.byte	18                              # DW_AT_high_pc
	.byte	6                               # DW_FORM_data4
	.byte	88                              # DW_AT_call_file
	.byte	11                              # DW_FORM_data1
	.byte	89                              # DW_AT_call_line
	.byte	11                              # DW_FORM_data1
	.byte	87                              # DW_AT_call_column
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	35                              # Abbreviation Code
	.byte	5                               # DW_TAG_formal_parameter
	.byte	0                               # DW_CHILDREN_no
	.byte	2                               # DW_AT_location
	.byte	24                              # DW_FORM_exprloc
	.byte	49                              # DW_AT_abstract_origin
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	36                              # Abbreviation Code
	.byte	5                               # DW_TAG_formal_parameter
	.byte	0                               # DW_CHILDREN_no
	.byte	28                              # DW_AT_const_value
	.byte	15                              # DW_FORM_udata
	.byte	49                              # DW_AT_abstract_origin
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	37                              # Abbreviation Code
	.byte	52                              # DW_TAG_variable
	.byte	0                               # DW_CHILDREN_no
	.byte	2                               # DW_AT_location
	.byte	34                              # DW_FORM_loclistx
	.byte	49                              # DW_AT_abstract_origin
	.byte	19                              # DW_FORM_ref4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	38                              # Abbreviation Code
	.byte	19                              # DW_TAG_structure_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	3                               # DW_AT_name
	.byte	37                              # DW_FORM_strx1
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	39                              # Abbreviation Code
	.byte	13                              # DW_TAG_member
	.byte	0                               # DW_CHILDREN_no
	.byte	73                              # DW_AT_type
	.byte	19                              # DW_FORM_ref4
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	56                              # DW_AT_data_member_location
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	40                              # Abbreviation Code
	.byte	23                              # DW_TAG_union_type
	.byte	1                               # DW_CHILDREN_yes
	.byte	11                              # DW_AT_byte_size
	.byte	11                              # DW_FORM_data1
	.byte	58                              # DW_AT_decl_file
	.byte	11                              # DW_FORM_data1
	.byte	59                              # DW_AT_decl_line
	.byte	11                              # DW_FORM_data1
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	0                               # EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 # Length of Unit
.Ldebug_info_start0:
	.short	5                               # DWARF version number
	.byte	1                               # DWARF Unit Type
	.byte	8                               # Address Size (in bytes)
	.long	.debug_abbrev                   # Offset Into Abbrev. Section
	.byte	1                               # Abbrev [1] 0xc:0x58f DW_TAG_compile_unit
	.byte	0                               # DW_AT_producer
	.short	12                              # DW_AT_language
	.byte	1                               # DW_AT_name
	.long	.Lstr_offsets_base0             # DW_AT_str_offsets_base
	.long	.Lline_table_start0             # DW_AT_stmt_list
	.byte	2                               # DW_AT_comp_dir
	.byte	2                               # DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       # DW_AT_high_pc
	.long	.Laddr_table_base0              # DW_AT_addr_base
	.long	.Lloclists_table_base0          # DW_AT_loclists_base
	.byte	2                               # Abbrev [2] 0x27:0xb DW_TAG_variable
	.byte	3                               # DW_AT_name
	.long	50                              # DW_AT_type
                                        # DW_AT_external
	.byte	0                               # DW_AT_decl_file
	.byte	15                              # DW_AT_decl_line
	.byte	2                               # DW_AT_location
	.byte	161
	.byte	0
	.byte	3                               # Abbrev [3] 0x32:0xc DW_TAG_array_type
	.long	62                              # DW_AT_type
	.byte	4                               # Abbrev [4] 0x37:0x6 DW_TAG_subrange_type
	.long	66                              # DW_AT_type
	.byte	13                              # DW_AT_count
	.byte	0                               # End Of Children Mark
	.byte	5                               # Abbrev [5] 0x3e:0x4 DW_TAG_base_type
	.byte	4                               # DW_AT_name
	.byte	6                               # DW_AT_encoding
	.byte	1                               # DW_AT_byte_size
	.byte	6                               # Abbrev [6] 0x42:0x4 DW_TAG_base_type
	.byte	5                               # DW_AT_name
	.byte	8                               # DW_AT_byte_size
	.byte	7                               # DW_AT_encoding
	.byte	2                               # Abbrev [2] 0x46:0xb DW_TAG_variable
	.byte	6                               # DW_AT_name
	.long	81                              # DW_AT_type
                                        # DW_AT_external
	.byte	0                               # DW_AT_decl_file
	.byte	20                              # DW_AT_decl_line
	.byte	2                               # DW_AT_location
	.byte	161
	.byte	1
	.byte	7                               # Abbrev [7] 0x51:0x17 DW_TAG_structure_type
	.byte	16                              # DW_AT_byte_size
	.byte	0                               # DW_AT_decl_file
	.byte	17                              # DW_AT_decl_line
	.byte	8                               # Abbrev [8] 0x55:0x9 DW_TAG_member
	.byte	7                               # DW_AT_name
	.long	104                             # DW_AT_type
	.byte	0                               # DW_AT_decl_file
	.byte	18                              # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	8                               # Abbrev [8] 0x5e:0x9 DW_TAG_member
	.byte	9                               # DW_AT_name
	.long	125                             # DW_AT_type
	.byte	0                               # DW_AT_decl_file
	.byte	19                              # DW_AT_decl_line
	.byte	8                               # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	9                               # Abbrev [9] 0x68:0x5 DW_TAG_pointer_type
	.long	109                             # DW_AT_type
	.byte	3                               # Abbrev [3] 0x6d:0xc DW_TAG_array_type
	.long	121                             # DW_AT_type
	.byte	4                               # Abbrev [4] 0x72:0x6 DW_TAG_subrange_type
	.long	66                              # DW_AT_type
	.byte	27                              # DW_AT_count
	.byte	0                               # End Of Children Mark
	.byte	5                               # Abbrev [5] 0x79:0x4 DW_TAG_base_type
	.byte	8                               # DW_AT_name
	.byte	5                               # DW_AT_encoding
	.byte	4                               # DW_AT_byte_size
	.byte	9                               # Abbrev [9] 0x7d:0x5 DW_TAG_pointer_type
	.long	130                             # DW_AT_type
	.byte	3                               # Abbrev [3] 0x82:0xf DW_TAG_array_type
	.long	121                             # DW_AT_type
	.byte	10                              # Abbrev [10] 0x87:0x9 DW_TAG_subrange_type
	.long	66                              # DW_AT_type
	.long	262144                          # DW_AT_count
	.byte	0                               # End Of Children Mark
	.byte	11                              # Abbrev [11] 0x91:0x9 DW_TAG_variable
	.byte	10                              # DW_AT_name
	.long	154                             # DW_AT_type
	.byte	2                               # DW_AT_decl_file
	.short	713                             # DW_AT_decl_line
	.byte	9                               # Abbrev [9] 0x9a:0x5 DW_TAG_pointer_type
	.long	159                             # DW_AT_type
	.byte	12                              # Abbrev [12] 0x9f:0x1a DW_TAG_subroutine_type
	.long	185                             # DW_AT_type
                                        # DW_AT_prototyped
	.byte	13                              # Abbrev [13] 0xa4:0x5 DW_TAG_formal_parameter
	.long	189                             # DW_AT_type
	.byte	13                              # Abbrev [13] 0xa9:0x5 DW_TAG_formal_parameter
	.long	195                             # DW_AT_type
	.byte	13                              # Abbrev [13] 0xae:0x5 DW_TAG_formal_parameter
	.long	207                             # DW_AT_type
	.byte	13                              # Abbrev [13] 0xb3:0x5 DW_TAG_formal_parameter
	.long	195                             # DW_AT_type
	.byte	0                               # End Of Children Mark
	.byte	5                               # Abbrev [5] 0xb9:0x4 DW_TAG_base_type
	.byte	11                              # DW_AT_name
	.byte	5                               # DW_AT_encoding
	.byte	8                               # DW_AT_byte_size
	.byte	9                               # Abbrev [9] 0xbd:0x5 DW_TAG_pointer_type
	.long	194                             # DW_AT_type
	.byte	14                              # Abbrev [14] 0xc2:0x1 DW_TAG_const_type
	.byte	15                              # Abbrev [15] 0xc3:0x8 DW_TAG_typedef
	.long	203                             # DW_AT_type
	.byte	13                              # DW_AT_name
	.byte	1                               # DW_AT_decl_file
	.byte	27                              # DW_AT_decl_line
	.byte	5                               # Abbrev [5] 0xcb:0x4 DW_TAG_base_type
	.byte	12                              # DW_AT_name
	.byte	7                               # DW_AT_encoding
	.byte	4                               # DW_AT_byte_size
	.byte	16                              # Abbrev [16] 0xcf:0x1 DW_TAG_pointer_type
	.byte	11                              # Abbrev [11] 0xd0:0x9 DW_TAG_variable
	.byte	14                              # DW_AT_name
	.long	217                             # DW_AT_type
	.byte	2                               # DW_AT_decl_file
	.short	3139                            # DW_AT_decl_line
	.byte	9                               # Abbrev [9] 0xd9:0x5 DW_TAG_pointer_type
	.long	222                             # DW_AT_type
	.byte	12                              # Abbrev [12] 0xde:0x15 DW_TAG_subroutine_type
	.long	207                             # DW_AT_type
                                        # DW_AT_prototyped
	.byte	13                              # Abbrev [13] 0xe3:0x5 DW_TAG_formal_parameter
	.long	207                             # DW_AT_type
	.byte	13                              # Abbrev [13] 0xe8:0x5 DW_TAG_formal_parameter
	.long	243                             # DW_AT_type
	.byte	13                              # Abbrev [13] 0xed:0x5 DW_TAG_formal_parameter
	.long	243                             # DW_AT_type
	.byte	0                               # End Of Children Mark
	.byte	15                              # Abbrev [15] 0xf3:0x8 DW_TAG_typedef
	.long	251                             # DW_AT_type
	.byte	16                              # DW_AT_name
	.byte	1                               # DW_AT_decl_file
	.byte	31                              # DW_AT_decl_line
	.byte	5                               # Abbrev [5] 0xfb:0x4 DW_TAG_base_type
	.byte	15                              # DW_AT_name
	.byte	7                               # DW_AT_encoding
	.byte	8                               # DW_AT_byte_size
	.byte	11                              # Abbrev [11] 0xff:0x9 DW_TAG_variable
	.byte	17                              # DW_AT_name
	.long	264                             # DW_AT_type
	.byte	2                               # DW_AT_decl_file
	.short	3157                            # DW_AT_decl_line
	.byte	9                               # Abbrev [9] 0x108:0x5 DW_TAG_pointer_type
	.long	269                             # DW_AT_type
	.byte	17                              # Abbrev [17] 0x10d:0xc DW_TAG_subroutine_type
                                        # DW_AT_prototyped
	.byte	13                              # Abbrev [13] 0x10e:0x5 DW_TAG_formal_parameter
	.long	207                             # DW_AT_type
	.byte	13                              # Abbrev [13] 0x113:0x5 DW_TAG_formal_parameter
	.long	243                             # DW_AT_type
	.byte	0                               # End Of Children Mark
	.byte	18                              # Abbrev [18] 0x119:0x64 DW_TAG_enumeration_type
	.long	203                             # DW_AT_type
	.byte	4                               # DW_AT_byte_size
	.byte	3                               # DW_AT_decl_file
	.byte	28                              # DW_AT_decl_line
	.byte	19                              # Abbrev [19] 0x121:0x3 DW_TAG_enumerator
	.byte	18                              # DW_AT_name
	.byte	0                               # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x124:0x3 DW_TAG_enumerator
	.byte	19                              # DW_AT_name
	.byte	1                               # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x127:0x3 DW_TAG_enumerator
	.byte	20                              # DW_AT_name
	.byte	2                               # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x12a:0x3 DW_TAG_enumerator
	.byte	21                              # DW_AT_name
	.byte	4                               # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x12d:0x3 DW_TAG_enumerator
	.byte	22                              # DW_AT_name
	.byte	6                               # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x130:0x3 DW_TAG_enumerator
	.byte	23                              # DW_AT_name
	.byte	8                               # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x133:0x3 DW_TAG_enumerator
	.byte	24                              # DW_AT_name
	.byte	12                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x136:0x3 DW_TAG_enumerator
	.byte	25                              # DW_AT_name
	.byte	17                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x139:0x3 DW_TAG_enumerator
	.byte	26                              # DW_AT_name
	.byte	22                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x13c:0x3 DW_TAG_enumerator
	.byte	27                              # DW_AT_name
	.byte	29                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x13f:0x3 DW_TAG_enumerator
	.byte	28                              # DW_AT_name
	.byte	33                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x142:0x3 DW_TAG_enumerator
	.byte	29                              # DW_AT_name
	.byte	41                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x145:0x3 DW_TAG_enumerator
	.byte	30                              # DW_AT_name
	.byte	46                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x148:0x3 DW_TAG_enumerator
	.byte	31                              # DW_AT_name
	.byte	47                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x14b:0x3 DW_TAG_enumerator
	.byte	32                              # DW_AT_name
	.byte	50                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x14e:0x3 DW_TAG_enumerator
	.byte	33                              # DW_AT_name
	.byte	51                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x151:0x3 DW_TAG_enumerator
	.byte	34                              # DW_AT_name
	.byte	92                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x154:0x3 DW_TAG_enumerator
	.byte	35                              # DW_AT_name
	.byte	94                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x157:0x3 DW_TAG_enumerator
	.byte	36                              # DW_AT_name
	.byte	98                              # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x15a:0x3 DW_TAG_enumerator
	.byte	37                              # DW_AT_name
	.byte	103                             # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x15d:0x3 DW_TAG_enumerator
	.byte	38                              # DW_AT_name
	.byte	108                             # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x160:0x4 DW_TAG_enumerator
	.byte	39                              # DW_AT_name
	.ascii	"\204\001"                      # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x164:0x4 DW_TAG_enumerator
	.byte	40                              # DW_AT_name
	.ascii	"\210\001"                      # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x168:0x4 DW_TAG_enumerator
	.byte	41                              # DW_AT_name
	.ascii	"\211\001"                      # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x16c:0x4 DW_TAG_enumerator
	.byte	42                              # DW_AT_name
	.ascii	"\217\001"                      # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x170:0x4 DW_TAG_enumerator
	.byte	43                              # DW_AT_name
	.ascii	"\377\001"                      # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x174:0x4 DW_TAG_enumerator
	.byte	44                              # DW_AT_name
	.ascii	"\206\002"                      # DW_AT_const_value
	.byte	19                              # Abbrev [19] 0x178:0x4 DW_TAG_enumerator
	.byte	45                              # DW_AT_name
	.ascii	"\207\002"                      # DW_AT_const_value
	.byte	0                               # End Of Children Mark
	.byte	20                              # Abbrev [20] 0x17d:0x21 DW_TAG_subprogram
	.byte	46                              # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	22                              # DW_AT_decl_line
                                        # DW_AT_prototyped
	.long	121                             # DW_AT_type
                                        # DW_AT_inline
	.byte	21                              # Abbrev [21] 0x185:0x8 DW_TAG_formal_parameter
	.byte	47                              # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	22                              # DW_AT_decl_line
	.long	414                             # DW_AT_type
	.byte	21                              # Abbrev [21] 0x18d:0x8 DW_TAG_formal_parameter
	.byte	75                              # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	22                              # DW_AT_decl_line
	.long	195                             # DW_AT_type
	.byte	22                              # Abbrev [22] 0x195:0x8 DW_TAG_variable
	.byte	117                             # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	24                              # DW_AT_decl_line
	.long	1041                            # DW_AT_type
	.byte	0                               # End Of Children Mark
	.byte	9                               # Abbrev [9] 0x19e:0x5 DW_TAG_pointer_type
	.long	419                             # DW_AT_type
	.byte	23                              # Abbrev [23] 0x1a3:0x17d DW_TAG_structure_type
	.byte	116                             # DW_AT_name
	.byte	192                             # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	5745                            # DW_AT_decl_line
	.byte	24                              # Abbrev [24] 0x1a9:0xa DW_TAG_member
	.byte	48                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5746                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1b3:0xa DW_TAG_member
	.byte	49                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5747                            # DW_AT_decl_line
	.byte	4                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1bd:0xa DW_TAG_member
	.byte	50                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5748                            # DW_AT_decl_line
	.byte	8                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1c7:0xa DW_TAG_member
	.byte	51                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5749                            # DW_AT_decl_line
	.byte	12                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1d1:0xa DW_TAG_member
	.byte	52                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5750                            # DW_AT_decl_line
	.byte	16                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1db:0xa DW_TAG_member
	.byte	53                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5751                            # DW_AT_decl_line
	.byte	20                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1e5:0xa DW_TAG_member
	.byte	54                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5752                            # DW_AT_decl_line
	.byte	24                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1ef:0xa DW_TAG_member
	.byte	55                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5753                            # DW_AT_decl_line
	.byte	28                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x1f9:0xa DW_TAG_member
	.byte	56                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5754                            # DW_AT_decl_line
	.byte	32                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x203:0xa DW_TAG_member
	.byte	57                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5755                            # DW_AT_decl_line
	.byte	36                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x20d:0xa DW_TAG_member
	.byte	58                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5756                            # DW_AT_decl_line
	.byte	40                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x217:0xa DW_TAG_member
	.byte	59                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5757                            # DW_AT_decl_line
	.byte	44                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x221:0xa DW_TAG_member
	.byte	60                              # DW_AT_name
	.long	800                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5758                            # DW_AT_decl_line
	.byte	48                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x22b:0xa DW_TAG_member
	.byte	61                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5759                            # DW_AT_decl_line
	.byte	68                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x235:0xa DW_TAG_member
	.byte	62                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5760                            # DW_AT_decl_line
	.byte	72                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x23f:0xa DW_TAG_member
	.byte	63                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5761                            # DW_AT_decl_line
	.byte	76                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x249:0xa DW_TAG_member
	.byte	64                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5762                            # DW_AT_decl_line
	.byte	80                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x253:0xa DW_TAG_member
	.byte	65                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5763                            # DW_AT_decl_line
	.byte	84                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x25d:0xa DW_TAG_member
	.byte	66                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5766                            # DW_AT_decl_line
	.byte	88                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x267:0xa DW_TAG_member
	.byte	67                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5767                            # DW_AT_decl_line
	.byte	92                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x271:0xa DW_TAG_member
	.byte	68                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5768                            # DW_AT_decl_line
	.byte	96                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x27b:0xa DW_TAG_member
	.byte	69                              # DW_AT_name
	.long	812                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5769                            # DW_AT_decl_line
	.byte	100                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x285:0xa DW_TAG_member
	.byte	70                              # DW_AT_name
	.long	812                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5770                            # DW_AT_decl_line
	.byte	116                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x28f:0xa DW_TAG_member
	.byte	71                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5771                            # DW_AT_decl_line
	.byte	132                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x299:0xa DW_TAG_member
	.byte	72                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5772                            # DW_AT_decl_line
	.byte	136                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x2a3:0xa DW_TAG_member
	.byte	73                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5775                            # DW_AT_decl_line
	.byte	140                             # DW_AT_data_member_location
	.byte	25                              # Abbrev [25] 0x2ad:0xa DW_TAG_member
	.long	695                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5776                            # DW_AT_decl_line
	.byte	8                               # DW_AT_alignment
	.byte	144                             # DW_AT_data_member_location
	.byte	26                              # Abbrev [26] 0x2b7:0x11 DW_TAG_union_type
	.byte	8                               # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	5776                            # DW_AT_decl_line
	.byte	8                               # DW_AT_alignment
	.byte	24                              # Abbrev [24] 0x2bd:0xa DW_TAG_member
	.byte	74                              # DW_AT_name
	.long	824                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5776                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	24                              # Abbrev [24] 0x2c8:0xa DW_TAG_member
	.byte	98                              # DW_AT_name
	.long	243                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5777                            # DW_AT_decl_line
	.byte	152                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x2d2:0xa DW_TAG_member
	.byte	99                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5778                            # DW_AT_decl_line
	.byte	160                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x2dc:0xa DW_TAG_member
	.byte	100                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5779                            # DW_AT_decl_line
	.byte	164                             # DW_AT_data_member_location
	.byte	25                              # Abbrev [25] 0x2e6:0xa DW_TAG_member
	.long	752                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5780                            # DW_AT_decl_line
	.byte	8                               # DW_AT_alignment
	.byte	168                             # DW_AT_data_member_location
	.byte	26                              # Abbrev [26] 0x2f0:0x11 DW_TAG_union_type
	.byte	8                               # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	5780                            # DW_AT_decl_line
	.byte	8                               # DW_AT_alignment
	.byte	24                              # Abbrev [24] 0x2f6:0xa DW_TAG_member
	.byte	101                             # DW_AT_name
	.long	1081                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5780                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	24                              # Abbrev [24] 0x301:0xa DW_TAG_member
	.byte	113                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5781                            # DW_AT_decl_line
	.byte	176                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x30b:0xa DW_TAG_member
	.byte	114                             # DW_AT_name
	.long	1053                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5782                            # DW_AT_decl_line
	.byte	180                             # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x315:0xa DW_TAG_member
	.byte	115                             # DW_AT_name
	.long	243                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5784                            # DW_AT_decl_line
	.byte	184                             # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	3                               # Abbrev [3] 0x320:0xc DW_TAG_array_type
	.long	195                             # DW_AT_type
	.byte	4                               # Abbrev [4] 0x325:0x6 DW_TAG_subrange_type
	.long	66                              # DW_AT_type
	.byte	5                               # DW_AT_count
	.byte	0                               # End Of Children Mark
	.byte	3                               # Abbrev [3] 0x32c:0xc DW_TAG_array_type
	.long	195                             # DW_AT_type
	.byte	4                               # Abbrev [4] 0x331:0x6 DW_TAG_subrange_type
	.long	66                              # DW_AT_type
	.byte	4                               # DW_AT_count
	.byte	0                               # End Of Children Mark
	.byte	9                               # Abbrev [9] 0x338:0x5 DW_TAG_pointer_type
	.long	829                             # DW_AT_type
	.byte	23                              # Abbrev [23] 0x33d:0xd4 DW_TAG_structure_type
	.byte	97                              # DW_AT_name
	.byte	56                              # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	6648                            # DW_AT_decl_line
	.byte	24                              # Abbrev [24] 0x343:0xa DW_TAG_member
	.byte	75                              # DW_AT_name
	.long	1041                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6649                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x34d:0xa DW_TAG_member
	.byte	78                              # DW_AT_name
	.long	1041                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6650                            # DW_AT_decl_line
	.byte	2                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x357:0xa DW_TAG_member
	.byte	79                              # DW_AT_name
	.long	1041                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6651                            # DW_AT_decl_line
	.byte	4                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x361:0xa DW_TAG_member
	.byte	80                              # DW_AT_name
	.long	1053                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6652                            # DW_AT_decl_line
	.byte	6                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x36b:0xa DW_TAG_member
	.byte	83                              # DW_AT_name
	.long	1053                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6653                            # DW_AT_decl_line
	.byte	7                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x375:0xa DW_TAG_member
	.byte	84                              # DW_AT_name
	.long	1053                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6654                            # DW_AT_decl_line
	.byte	8                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x37f:0xa DW_TAG_member
	.byte	85                              # DW_AT_name
	.long	1053                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6655                            # DW_AT_decl_line
	.byte	9                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x389:0xa DW_TAG_member
	.byte	86                              # DW_AT_name
	.long	1065                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6656                            # DW_AT_decl_line
	.byte	10                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x393:0xa DW_TAG_member
	.byte	88                              # DW_AT_name
	.long	1065                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6657                            # DW_AT_decl_line
	.byte	12                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x39d:0xa DW_TAG_member
	.byte	89                              # DW_AT_name
	.long	1065                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6658                            # DW_AT_decl_line
	.byte	14                              # DW_AT_data_member_location
	.byte	27                              # Abbrev [27] 0x3a7:0x9 DW_TAG_member
	.long	944                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6659                            # DW_AT_decl_line
	.byte	16                              # DW_AT_data_member_location
	.byte	28                              # Abbrev [28] 0x3b0:0x4c DW_TAG_union_type
	.byte	32                              # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	6659                            # DW_AT_decl_line
	.byte	27                              # Abbrev [27] 0x3b5:0x9 DW_TAG_member
	.long	958                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6660                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	29                              # Abbrev [29] 0x3be:0x1a DW_TAG_structure_type
	.byte	8                               # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	6660                            # DW_AT_decl_line
	.byte	24                              # Abbrev [24] 0x3c3:0xa DW_TAG_member
	.byte	90                              # DW_AT_name
	.long	1073                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6661                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x3cd:0xa DW_TAG_member
	.byte	92                              # DW_AT_name
	.long	1073                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6662                            # DW_AT_decl_line
	.byte	4                               # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	27                              # Abbrev [27] 0x3d8:0x9 DW_TAG_member
	.long	993                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6664                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	29                              # Abbrev [29] 0x3e1:0x1a DW_TAG_structure_type
	.byte	32                              # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	6664                            # DW_AT_decl_line
	.byte	24                              # Abbrev [24] 0x3e6:0xa DW_TAG_member
	.byte	93                              # DW_AT_name
	.long	812                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6665                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x3f0:0xa DW_TAG_member
	.byte	94                              # DW_AT_name
	.long	812                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6666                            # DW_AT_decl_line
	.byte	16                              # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	0                               # End Of Children Mark
	.byte	24                              # Abbrev [24] 0x3fc:0xa DW_TAG_member
	.byte	95                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6669                            # DW_AT_decl_line
	.byte	48                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x406:0xa DW_TAG_member
	.byte	96                              # DW_AT_name
	.long	1073                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	6670                            # DW_AT_decl_line
	.byte	52                              # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	15                              # Abbrev [15] 0x411:0x8 DW_TAG_typedef
	.long	1049                            # DW_AT_type
	.byte	77                              # DW_AT_name
	.byte	1                               # DW_AT_decl_file
	.byte	24                              # DW_AT_decl_line
	.byte	5                               # Abbrev [5] 0x419:0x4 DW_TAG_base_type
	.byte	76                              # DW_AT_name
	.byte	7                               # DW_AT_encoding
	.byte	2                               # DW_AT_byte_size
	.byte	15                              # Abbrev [15] 0x41d:0x8 DW_TAG_typedef
	.long	1061                            # DW_AT_type
	.byte	82                              # DW_AT_name
	.byte	1                               # DW_AT_decl_file
	.byte	21                              # DW_AT_decl_line
	.byte	5                               # Abbrev [5] 0x425:0x4 DW_TAG_base_type
	.byte	81                              # DW_AT_name
	.byte	8                               # DW_AT_encoding
	.byte	1                               # DW_AT_byte_size
	.byte	15                              # Abbrev [15] 0x429:0x8 DW_TAG_typedef
	.long	1041                            # DW_AT_type
	.byte	87                              # DW_AT_name
	.byte	5                               # DW_AT_decl_file
	.byte	25                              # DW_AT_decl_line
	.byte	15                              # Abbrev [15] 0x431:0x8 DW_TAG_typedef
	.long	195                             # DW_AT_type
	.byte	91                              # DW_AT_name
	.byte	5                               # DW_AT_decl_file
	.byte	27                              # DW_AT_decl_line
	.byte	9                               # Abbrev [9] 0x439:0x5 DW_TAG_pointer_type
	.long	1086                            # DW_AT_type
	.byte	23                              # Abbrev [23] 0x43e:0x93 DW_TAG_structure_type
	.byte	112                             # DW_AT_name
	.byte	80                              # DW_AT_byte_size
	.byte	4                               # DW_AT_decl_file
	.short	5841                            # DW_AT_decl_line
	.byte	24                              # Abbrev [24] 0x444:0xa DW_TAG_member
	.byte	102                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5842                            # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x44e:0xa DW_TAG_member
	.byte	66                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5843                            # DW_AT_decl_line
	.byte	4                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x458:0xa DW_TAG_member
	.byte	7                               # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5844                            # DW_AT_decl_line
	.byte	8                               # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x462:0xa DW_TAG_member
	.byte	52                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5845                            # DW_AT_decl_line
	.byte	12                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x46c:0xa DW_TAG_member
	.byte	50                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5846                            # DW_AT_decl_line
	.byte	16                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x476:0xa DW_TAG_member
	.byte	56                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5847                            # DW_AT_decl_line
	.byte	20                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x480:0xa DW_TAG_member
	.byte	103                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5849                            # DW_AT_decl_line
	.byte	24                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x48a:0xa DW_TAG_member
	.byte	104                             # DW_AT_name
	.long	812                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5850                            # DW_AT_decl_line
	.byte	28                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x494:0xa DW_TAG_member
	.byte	105                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5851                            # DW_AT_decl_line
	.byte	44                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x49e:0xa DW_TAG_member
	.byte	106                             # DW_AT_name
	.long	1065                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5852                            # DW_AT_decl_line
	.byte	48                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x4a8:0xa DW_TAG_member
	.byte	107                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5854                            # DW_AT_decl_line
	.byte	52                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x4b2:0xa DW_TAG_member
	.byte	108                             # DW_AT_name
	.long	812                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5855                            # DW_AT_decl_line
	.byte	56                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x4bc:0xa DW_TAG_member
	.byte	109                             # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5856                            # DW_AT_decl_line
	.byte	72                              # DW_AT_data_member_location
	.byte	24                              # Abbrev [24] 0x4c6:0xa DW_TAG_member
	.byte	110                             # DW_AT_name
	.long	1233                            # DW_AT_type
	.byte	4                               # DW_AT_decl_file
	.short	5857                            # DW_AT_decl_line
	.byte	76                              # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	15                              # Abbrev [15] 0x4d1:0x8 DW_TAG_typedef
	.long	121                             # DW_AT_type
	.byte	111                             # DW_AT_name
	.byte	1                               # DW_AT_decl_file
	.byte	26                              # DW_AT_decl_line
	.byte	30                              # Abbrev [30] 0x4d9:0x5e DW_TAG_subprogram
	.byte	2                               # DW_AT_low_pc
	.long	.Lfunc_end0-.Lfunc_begin0       # DW_AT_high_pc
	.byte	1                               # DW_AT_frame_base
	.byte	90
                                        # DW_AT_call_all_calls
	.byte	118                             # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	32                              # DW_AT_decl_line
                                        # DW_AT_prototyped
	.long	121                             # DW_AT_type
                                        # DW_AT_external
	.byte	31                              # Abbrev [31] 0x4e8:0x9 DW_TAG_formal_parameter
	.byte	0                               # DW_AT_location
	.byte	47                              # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	32                              # DW_AT_decl_line
	.long	414                             # DW_AT_type
	.byte	32                              # Abbrev [32] 0x4f1:0x9 DW_TAG_variable
	.byte	1                               # DW_AT_location
	.byte	119                             # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	36                              # DW_AT_decl_line
	.long	1041                            # DW_AT_type
	.byte	33                              # Abbrev [33] 0x4fa:0x9 DW_TAG_variable
	.byte	14                              # DW_AT_const_value
	.byte	75                              # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	37                              # DW_AT_decl_line
	.long	195                             # DW_AT_type
	.byte	32                              # Abbrev [32] 0x503:0x9 DW_TAG_variable
	.byte	3                               # DW_AT_location
	.byte	120                             # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	34                              # DW_AT_decl_line
	.long	1335                            # DW_AT_type
	.byte	32                              # Abbrev [32] 0x50c:0x9 DW_TAG_variable
	.byte	4                               # DW_AT_location
	.byte	126                             # DW_AT_name
	.byte	0                               # DW_AT_decl_file
	.byte	35                              # DW_AT_decl_line
	.long	1053                            # DW_AT_type
	.byte	34                              # Abbrev [34] 0x515:0x21 DW_TAG_inlined_subroutine
	.long	381                             # DW_AT_abstract_origin
	.byte	3                               # DW_AT_low_pc
	.long	.Ltmp27-.Ltmp16                 # DW_AT_high_pc
	.byte	0                               # DW_AT_call_file
	.byte	44                              # DW_AT_call_line
	.byte	6                               # DW_AT_call_column
	.byte	35                              # Abbrev [35] 0x522:0x7 DW_TAG_formal_parameter
	.byte	1                               # DW_AT_location
	.byte	86
	.long	389                             # DW_AT_abstract_origin
	.byte	36                              # Abbrev [36] 0x529:0x6 DW_TAG_formal_parameter
	.byte	14                              # DW_AT_const_value
	.long	397                             # DW_AT_abstract_origin
	.byte	37                              # Abbrev [37] 0x52f:0x6 DW_TAG_variable
	.byte	2                               # DW_AT_location
	.long	405                             # DW_AT_abstract_origin
	.byte	0                               # End Of Children Mark
	.byte	0                               # End Of Children Mark
	.byte	9                               # Abbrev [9] 0x537:0x5 DW_TAG_pointer_type
	.long	1340                            # DW_AT_type
	.byte	38                              # Abbrev [38] 0x53c:0x52 DW_TAG_structure_type
	.byte	125                             # DW_AT_name
	.byte	24                              # DW_AT_byte_size
	.byte	6                               # DW_AT_decl_file
	.byte	6                               # DW_AT_decl_line
	.byte	8                               # Abbrev [8] 0x541:0x9 DW_TAG_member
	.byte	121                             # DW_AT_name
	.long	1073                            # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	7                               # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	8                               # Abbrev [8] 0x54a:0x9 DW_TAG_member
	.byte	122                             # DW_AT_name
	.long	1073                            # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	8                               # DW_AT_decl_line
	.byte	4                               # DW_AT_data_member_location
	.byte	39                              # Abbrev [39] 0x553:0x8 DW_TAG_member
	.long	1371                            # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	9                               # DW_AT_decl_line
	.byte	8                               # DW_AT_data_member_location
	.byte	40                              # Abbrev [40] 0x55b:0x17 DW_TAG_union_type
	.byte	4                               # DW_AT_byte_size
	.byte	6                               # DW_AT_decl_file
	.byte	9                               # DW_AT_decl_line
	.byte	8                               # Abbrev [8] 0x55f:0x9 DW_TAG_member
	.byte	123                             # DW_AT_name
	.long	1073                            # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	10                              # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	8                               # Abbrev [8] 0x568:0x9 DW_TAG_member
	.byte	124                             # DW_AT_name
	.long	1422                            # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	11                              # DW_AT_decl_line
	.byte	0                               # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	8                               # Abbrev [8] 0x572:0x9 DW_TAG_member
	.byte	85                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	13                              # DW_AT_decl_line
	.byte	12                              # DW_AT_data_member_location
	.byte	8                               # Abbrev [8] 0x57b:0x9 DW_TAG_member
	.byte	49                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	14                              # DW_AT_decl_line
	.byte	16                              # DW_AT_data_member_location
	.byte	8                               # Abbrev [8] 0x584:0x9 DW_TAG_member
	.byte	58                              # DW_AT_name
	.long	195                             # DW_AT_type
	.byte	6                               # DW_AT_decl_file
	.byte	15                              # DW_AT_decl_line
	.byte	20                              # DW_AT_data_member_location
	.byte	0                               # End Of Children Mark
	.byte	3                               # Abbrev [3] 0x58e:0xc DW_TAG_array_type
	.long	1065                            # DW_AT_type
	.byte	4                               # Abbrev [4] 0x593:0x6 DW_TAG_subrange_type
	.long	66                              # DW_AT_type
	.byte	2                               # DW_AT_count
	.byte	0                               # End Of Children Mark
	.byte	0                               # End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_str_offsets,"",@progbits
	.long	512                             # Length of String Offsets Set
	.short	5
	.short	0
.Lstr_offsets_base0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"Ubuntu clang version 14.0.0-1ubuntu1" # string offset=0
.Linfo_string1:
	.asciz	"sockfilter.bpf.c"              # string offset=37
.Linfo_string2:
	.asciz	"/home/luis/Documents/desk/proj/spectector-bpf/spectector/tests/bpf/external-samples/libbpf-bootstrap/examples/c" # string offset=54
.Linfo_string3:
	.asciz	"LICENSE"                       # string offset=166
.Linfo_string4:
	.asciz	"char"                          # string offset=174
.Linfo_string5:
	.asciz	"__ARRAY_SIZE_TYPE__"           # string offset=179
.Linfo_string6:
	.asciz	"rb"                            # string offset=199
.Linfo_string7:
	.asciz	"type"                          # string offset=202
.Linfo_string8:
	.asciz	"int"                           # string offset=207
.Linfo_string9:
	.asciz	"max_entries"                   # string offset=211
.Linfo_string10:
	.asciz	"bpf_skb_load_bytes"            # string offset=223
.Linfo_string11:
	.asciz	"long"                          # string offset=242
.Linfo_string12:
	.asciz	"unsigned int"                  # string offset=247
.Linfo_string13:
	.asciz	"__u32"                         # string offset=260
.Linfo_string14:
	.asciz	"bpf_ringbuf_reserve"           # string offset=266
.Linfo_string15:
	.asciz	"unsigned long long"            # string offset=286
.Linfo_string16:
	.asciz	"__u64"                         # string offset=305
.Linfo_string17:
	.asciz	"bpf_ringbuf_submit"            # string offset=311
.Linfo_string18:
	.asciz	"IPPROTO_IP"                    # string offset=330
.Linfo_string19:
	.asciz	"IPPROTO_ICMP"                  # string offset=341
.Linfo_string20:
	.asciz	"IPPROTO_IGMP"                  # string offset=354
.Linfo_string21:
	.asciz	"IPPROTO_IPIP"                  # string offset=367
.Linfo_string22:
	.asciz	"IPPROTO_TCP"                   # string offset=380
.Linfo_string23:
	.asciz	"IPPROTO_EGP"                   # string offset=392
.Linfo_string24:
	.asciz	"IPPROTO_PUP"                   # string offset=404
.Linfo_string25:
	.asciz	"IPPROTO_UDP"                   # string offset=416
.Linfo_string26:
	.asciz	"IPPROTO_IDP"                   # string offset=428
.Linfo_string27:
	.asciz	"IPPROTO_TP"                    # string offset=440
.Linfo_string28:
	.asciz	"IPPROTO_DCCP"                  # string offset=451
.Linfo_string29:
	.asciz	"IPPROTO_IPV6"                  # string offset=464
.Linfo_string30:
	.asciz	"IPPROTO_RSVP"                  # string offset=477
.Linfo_string31:
	.asciz	"IPPROTO_GRE"                   # string offset=490
.Linfo_string32:
	.asciz	"IPPROTO_ESP"                   # string offset=502
.Linfo_string33:
	.asciz	"IPPROTO_AH"                    # string offset=514
.Linfo_string34:
	.asciz	"IPPROTO_MTP"                   # string offset=525
.Linfo_string35:
	.asciz	"IPPROTO_BEETPH"                # string offset=537
.Linfo_string36:
	.asciz	"IPPROTO_ENCAP"                 # string offset=552
.Linfo_string37:
	.asciz	"IPPROTO_PIM"                   # string offset=566
.Linfo_string38:
	.asciz	"IPPROTO_COMP"                  # string offset=578
.Linfo_string39:
	.asciz	"IPPROTO_SCTP"                  # string offset=591
.Linfo_string40:
	.asciz	"IPPROTO_UDPLITE"               # string offset=604
.Linfo_string41:
	.asciz	"IPPROTO_MPLS"                  # string offset=620
.Linfo_string42:
	.asciz	"IPPROTO_ETHERNET"              # string offset=633
.Linfo_string43:
	.asciz	"IPPROTO_RAW"                   # string offset=650
.Linfo_string44:
	.asciz	"IPPROTO_MPTCP"                 # string offset=662
.Linfo_string45:
	.asciz	"IPPROTO_MAX"                   # string offset=676
.Linfo_string46:
	.asciz	"ip_is_fragment"                # string offset=688
.Linfo_string47:
	.asciz	"skb"                           # string offset=703
.Linfo_string48:
	.asciz	"len"                           # string offset=707
.Linfo_string49:
	.asciz	"pkt_type"                      # string offset=711
.Linfo_string50:
	.asciz	"mark"                          # string offset=720
.Linfo_string51:
	.asciz	"queue_mapping"                 # string offset=725
.Linfo_string52:
	.asciz	"protocol"                      # string offset=739
.Linfo_string53:
	.asciz	"vlan_present"                  # string offset=748
.Linfo_string54:
	.asciz	"vlan_tci"                      # string offset=761
.Linfo_string55:
	.asciz	"vlan_proto"                    # string offset=770
.Linfo_string56:
	.asciz	"priority"                      # string offset=781
.Linfo_string57:
	.asciz	"ingress_ifindex"               # string offset=790
.Linfo_string58:
	.asciz	"ifindex"                       # string offset=806
.Linfo_string59:
	.asciz	"tc_index"                      # string offset=814
.Linfo_string60:
	.asciz	"cb"                            # string offset=823
.Linfo_string61:
	.asciz	"hash"                          # string offset=826
.Linfo_string62:
	.asciz	"tc_classid"                    # string offset=831
.Linfo_string63:
	.asciz	"data"                          # string offset=842
.Linfo_string64:
	.asciz	"data_end"                      # string offset=847
.Linfo_string65:
	.asciz	"napi_id"                       # string offset=856
.Linfo_string66:
	.asciz	"family"                        # string offset=864
.Linfo_string67:
	.asciz	"remote_ip4"                    # string offset=871
.Linfo_string68:
	.asciz	"local_ip4"                     # string offset=882
.Linfo_string69:
	.asciz	"remote_ip6"                    # string offset=892
.Linfo_string70:
	.asciz	"local_ip6"                     # string offset=903
.Linfo_string71:
	.asciz	"remote_port"                   # string offset=913
.Linfo_string72:
	.asciz	"local_port"                    # string offset=925
.Linfo_string73:
	.asciz	"data_meta"                     # string offset=936
.Linfo_string74:
	.asciz	"flow_keys"                     # string offset=946
.Linfo_string75:
	.asciz	"nhoff"                         # string offset=956
.Linfo_string76:
	.asciz	"unsigned short"                # string offset=962
.Linfo_string77:
	.asciz	"__u16"                         # string offset=977
.Linfo_string78:
	.asciz	"thoff"                         # string offset=983
.Linfo_string79:
	.asciz	"addr_proto"                    # string offset=989
.Linfo_string80:
	.asciz	"is_frag"                       # string offset=1000
.Linfo_string81:
	.asciz	"unsigned char"                 # string offset=1008
.Linfo_string82:
	.asciz	"__u8"                          # string offset=1022
.Linfo_string83:
	.asciz	"is_first_frag"                 # string offset=1027
.Linfo_string84:
	.asciz	"is_encap"                      # string offset=1041
.Linfo_string85:
	.asciz	"ip_proto"                      # string offset=1050
.Linfo_string86:
	.asciz	"n_proto"                       # string offset=1059
.Linfo_string87:
	.asciz	"__be16"                        # string offset=1067
.Linfo_string88:
	.asciz	"sport"                         # string offset=1074
.Linfo_string89:
	.asciz	"dport"                         # string offset=1080
.Linfo_string90:
	.asciz	"ipv4_src"                      # string offset=1086
.Linfo_string91:
	.asciz	"__be32"                        # string offset=1095
.Linfo_string92:
	.asciz	"ipv4_dst"                      # string offset=1102
.Linfo_string93:
	.asciz	"ipv6_src"                      # string offset=1111
.Linfo_string94:
	.asciz	"ipv6_dst"                      # string offset=1120
.Linfo_string95:
	.asciz	"flags"                         # string offset=1129
.Linfo_string96:
	.asciz	"flow_label"                    # string offset=1135
.Linfo_string97:
	.asciz	"bpf_flow_keys"                 # string offset=1146
.Linfo_string98:
	.asciz	"tstamp"                        # string offset=1160
.Linfo_string99:
	.asciz	"wire_len"                      # string offset=1167
.Linfo_string100:
	.asciz	"gso_segs"                      # string offset=1176
.Linfo_string101:
	.asciz	"sk"                            # string offset=1185
.Linfo_string102:
	.asciz	"bound_dev_if"                  # string offset=1188
.Linfo_string103:
	.asciz	"src_ip4"                       # string offset=1201
.Linfo_string104:
	.asciz	"src_ip6"                       # string offset=1209
.Linfo_string105:
	.asciz	"src_port"                      # string offset=1217
.Linfo_string106:
	.asciz	"dst_port"                      # string offset=1226
.Linfo_string107:
	.asciz	"dst_ip4"                       # string offset=1235
.Linfo_string108:
	.asciz	"dst_ip6"                       # string offset=1243
.Linfo_string109:
	.asciz	"state"                         # string offset=1251
.Linfo_string110:
	.asciz	"rx_queue_mapping"              # string offset=1257
.Linfo_string111:
	.asciz	"__s32"                         # string offset=1274
.Linfo_string112:
	.asciz	"bpf_sock"                      # string offset=1280
.Linfo_string113:
	.asciz	"gso_size"                      # string offset=1289
.Linfo_string114:
	.asciz	"tstamp_type"                   # string offset=1298
.Linfo_string115:
	.asciz	"hwtstamp"                      # string offset=1310
.Linfo_string116:
	.asciz	"__sk_buff"                     # string offset=1319
.Linfo_string117:
	.asciz	"frag_off"                      # string offset=1329
.Linfo_string118:
	.asciz	"socket_handler"                # string offset=1338
.Linfo_string119:
	.asciz	"proto"                         # string offset=1353
.Linfo_string120:
	.asciz	"e"                             # string offset=1359
.Linfo_string121:
	.asciz	"src_addr"                      # string offset=1361
.Linfo_string122:
	.asciz	"dst_addr"                      # string offset=1370
.Linfo_string123:
	.asciz	"ports"                         # string offset=1379
.Linfo_string124:
	.asciz	"port16"                        # string offset=1385
.Linfo_string125:
	.asciz	"so_event"                      # string offset=1392
.Linfo_string126:
	.asciz	"verlen"                        # string offset=1401
	.section	.debug_str_offsets,"",@progbits
	.long	.Linfo_string0
	.long	.Linfo_string1
	.long	.Linfo_string2
	.long	.Linfo_string3
	.long	.Linfo_string4
	.long	.Linfo_string5
	.long	.Linfo_string6
	.long	.Linfo_string7
	.long	.Linfo_string8
	.long	.Linfo_string9
	.long	.Linfo_string10
	.long	.Linfo_string11
	.long	.Linfo_string12
	.long	.Linfo_string13
	.long	.Linfo_string14
	.long	.Linfo_string15
	.long	.Linfo_string16
	.long	.Linfo_string17
	.long	.Linfo_string18
	.long	.Linfo_string19
	.long	.Linfo_string20
	.long	.Linfo_string21
	.long	.Linfo_string22
	.long	.Linfo_string23
	.long	.Linfo_string24
	.long	.Linfo_string25
	.long	.Linfo_string26
	.long	.Linfo_string27
	.long	.Linfo_string28
	.long	.Linfo_string29
	.long	.Linfo_string30
	.long	.Linfo_string31
	.long	.Linfo_string32
	.long	.Linfo_string33
	.long	.Linfo_string34
	.long	.Linfo_string35
	.long	.Linfo_string36
	.long	.Linfo_string37
	.long	.Linfo_string38
	.long	.Linfo_string39
	.long	.Linfo_string40
	.long	.Linfo_string41
	.long	.Linfo_string42
	.long	.Linfo_string43
	.long	.Linfo_string44
	.long	.Linfo_string45
	.long	.Linfo_string46
	.long	.Linfo_string47
	.long	.Linfo_string48
	.long	.Linfo_string49
	.long	.Linfo_string50
	.long	.Linfo_string51
	.long	.Linfo_string52
	.long	.Linfo_string53
	.long	.Linfo_string54
	.long	.Linfo_string55
	.long	.Linfo_string56
	.long	.Linfo_string57
	.long	.Linfo_string58
	.long	.Linfo_string59
	.long	.Linfo_string60
	.long	.Linfo_string61
	.long	.Linfo_string62
	.long	.Linfo_string63
	.long	.Linfo_string64
	.long	.Linfo_string65
	.long	.Linfo_string66
	.long	.Linfo_string67
	.long	.Linfo_string68
	.long	.Linfo_string69
	.long	.Linfo_string70
	.long	.Linfo_string71
	.long	.Linfo_string72
	.long	.Linfo_string73
	.long	.Linfo_string74
	.long	.Linfo_string75
	.long	.Linfo_string76
	.long	.Linfo_string77
	.long	.Linfo_string78
	.long	.Linfo_string79
	.long	.Linfo_string80
	.long	.Linfo_string81
	.long	.Linfo_string82
	.long	.Linfo_string83
	.long	.Linfo_string84
	.long	.Linfo_string85
	.long	.Linfo_string86
	.long	.Linfo_string87
	.long	.Linfo_string88
	.long	.Linfo_string89
	.long	.Linfo_string90
	.long	.Linfo_string91
	.long	.Linfo_string92
	.long	.Linfo_string93
	.long	.Linfo_string94
	.long	.Linfo_string95
	.long	.Linfo_string96
	.long	.Linfo_string97
	.long	.Linfo_string98
	.long	.Linfo_string99
	.long	.Linfo_string100
	.long	.Linfo_string101
	.long	.Linfo_string102
	.long	.Linfo_string103
	.long	.Linfo_string104
	.long	.Linfo_string105
	.long	.Linfo_string106
	.long	.Linfo_string107
	.long	.Linfo_string108
	.long	.Linfo_string109
	.long	.Linfo_string110
	.long	.Linfo_string111
	.long	.Linfo_string112
	.long	.Linfo_string113
	.long	.Linfo_string114
	.long	.Linfo_string115
	.long	.Linfo_string116
	.long	.Linfo_string117
	.long	.Linfo_string118
	.long	.Linfo_string119
	.long	.Linfo_string120
	.long	.Linfo_string121
	.long	.Linfo_string122
	.long	.Linfo_string123
	.long	.Linfo_string124
	.long	.Linfo_string125
	.long	.Linfo_string126
	.section	.debug_addr,"",@progbits
	.long	.Ldebug_addr_end0-.Ldebug_addr_start0 # Length of contribution
.Ldebug_addr_start0:
	.short	5                               # DWARF version number
	.byte	8                               # Address size
	.byte	0                               # Segment selector size
.Laddr_table_base0:
	.quad	LICENSE
	.quad	rb
	.quad	.Lfunc_begin0
	.quad	.Ltmp16
.Ldebug_addr_end0:
	.section	.BTF,"",@progbits
	.short	60319                           # 0xeb9f
	.byte	1
	.byte	0
	.long	24
	.long	0
	.long	952
	.long	952
	.long	1528
	.long	0                               # BTF_KIND_PTR(id = 1)
	.long	33554432                        # 0x2000000
	.long	3
	.long	1                               # BTF_KIND_INT(id = 2)
	.long	16777216                        # 0x1000000
	.long	4
	.long	16777248                        # 0x1000020
	.long	0                               # BTF_KIND_ARRAY(id = 3)
	.long	50331648                        # 0x3000000
	.long	0
	.long	2
	.long	4
	.long	27
	.long	5                               # BTF_KIND_INT(id = 4)
	.long	16777216                        # 0x1000000
	.long	4
	.long	32                              # 0x20
	.long	0                               # BTF_KIND_PTR(id = 5)
	.long	33554432                        # 0x2000000
	.long	6
	.long	0                               # BTF_KIND_ARRAY(id = 6)
	.long	50331648                        # 0x3000000
	.long	0
	.long	2
	.long	4
	.long	262144
	.long	0                               # BTF_KIND_STRUCT(id = 7)
	.long	67108866                        # 0x4000002
	.long	16
	.long	25
	.long	1
	.long	0                               # 0x0
	.long	30
	.long	5
	.long	64                              # 0x40
	.long	42                              # BTF_KIND_VAR(id = 8)
	.long	234881024                       # 0xe000000
	.long	7
	.long	1
	.long	0                               # BTF_KIND_PTR(id = 9)
	.long	33554432                        # 0x2000000
	.long	10
	.long	45                              # BTF_KIND_STRUCT(id = 10)
	.long	67108898                        # 0x4000022
	.long	192
	.long	55
	.long	11
	.long	0                               # 0x0
	.long	59
	.long	11
	.long	32                              # 0x20
	.long	68
	.long	11
	.long	64                              # 0x40
	.long	73
	.long	11
	.long	96                              # 0x60
	.long	87
	.long	11
	.long	128                             # 0x80
	.long	96
	.long	11
	.long	160                             # 0xa0
	.long	109
	.long	11
	.long	192                             # 0xc0
	.long	118
	.long	11
	.long	224                             # 0xe0
	.long	129
	.long	11
	.long	256                             # 0x100
	.long	138
	.long	11
	.long	288                             # 0x120
	.long	154
	.long	11
	.long	320                             # 0x140
	.long	162
	.long	11
	.long	352                             # 0x160
	.long	171
	.long	13
	.long	384                             # 0x180
	.long	174
	.long	11
	.long	544                             # 0x220
	.long	179
	.long	11
	.long	576                             # 0x240
	.long	190
	.long	11
	.long	608                             # 0x260
	.long	195
	.long	11
	.long	640                             # 0x280
	.long	204
	.long	11
	.long	672                             # 0x2a0
	.long	212
	.long	11
	.long	704                             # 0x2c0
	.long	219
	.long	11
	.long	736                             # 0x2e0
	.long	230
	.long	11
	.long	768                             # 0x300
	.long	240
	.long	14
	.long	800                             # 0x320
	.long	251
	.long	14
	.long	928                             # 0x3a0
	.long	261
	.long	11
	.long	1056                            # 0x420
	.long	273
	.long	11
	.long	1088                            # 0x440
	.long	284
	.long	11
	.long	1120                            # 0x460
	.long	0
	.long	15
	.long	1152                            # 0x480
	.long	294
	.long	17
	.long	1216                            # 0x4c0
	.long	301
	.long	11
	.long	1280                            # 0x500
	.long	310
	.long	11
	.long	1312                            # 0x520
	.long	0
	.long	19
	.long	1344                            # 0x540
	.long	319
	.long	11
	.long	1408                            # 0x580
	.long	328
	.long	21
	.long	1440                            # 0x5a0
	.long	340
	.long	17
	.long	1472                            # 0x5c0
	.long	349                             # BTF_KIND_TYPEDEF(id = 11)
	.long	134217728                       # 0x8000000
	.long	12
	.long	355                             # BTF_KIND_INT(id = 12)
	.long	16777216                        # 0x1000000
	.long	4
	.long	32                              # 0x20
	.long	0                               # BTF_KIND_ARRAY(id = 13)
	.long	50331648                        # 0x3000000
	.long	0
	.long	11
	.long	4
	.long	5
	.long	0                               # BTF_KIND_ARRAY(id = 14)
	.long	50331648                        # 0x3000000
	.long	0
	.long	11
	.long	4
	.long	4
	.long	0                               # BTF_KIND_UNION(id = 15)
	.long	83886081                        # 0x5000001
	.long	8
	.long	368
	.long	16
	.long	0                               # 0x0
	.long	0                               # BTF_KIND_PTR(id = 16)
	.long	33554432                        # 0x2000000
	.long	30
	.long	378                             # BTF_KIND_TYPEDEF(id = 17)
	.long	134217728                       # 0x8000000
	.long	18
	.long	384                             # BTF_KIND_INT(id = 18)
	.long	16777216                        # 0x1000000
	.long	8
	.long	64                              # 0x40
	.long	0                               # BTF_KIND_UNION(id = 19)
	.long	83886081                        # 0x5000001
	.long	8
	.long	403
	.long	20
	.long	0                               # 0x0
	.long	0                               # BTF_KIND_PTR(id = 20)
	.long	33554432                        # 0x2000000
	.long	31
	.long	406                             # BTF_KIND_TYPEDEF(id = 21)
	.long	134217728                       # 0x8000000
	.long	22
	.long	411                             # BTF_KIND_INT(id = 22)
	.long	16777216                        # 0x1000000
	.long	1
	.long	8                               # 0x8
	.long	0                               # BTF_KIND_FUNC_PROTO(id = 23)
	.long	218103809                       # 0xd000001
	.long	2
	.long	425
	.long	9
	.long	429                             # BTF_KIND_FUNC(id = 24)
	.long	201326593                       # 0xc000001
	.long	23
	.long	1478                            # BTF_KIND_INT(id = 25)
	.long	16777216                        # 0x1000000
	.long	1
	.long	16777224                        # 0x1000008
	.long	0                               # BTF_KIND_ARRAY(id = 26)
	.long	50331648                        # 0x3000000
	.long	0
	.long	25
	.long	4
	.long	13
	.long	1483                            # BTF_KIND_VAR(id = 27)
	.long	234881024                       # 0xe000000
	.long	26
	.long	1
	.long	1491                            # BTF_KIND_DATASEC(id = 28)
	.long	251658241                       # 0xf000001
	.long	0
	.long	8
	.long	rb
	.long	16
	.long	1497                            # BTF_KIND_DATASEC(id = 29)
	.long	251658241                       # 0xf000001
	.long	0
	.long	27
	.long	LICENSE
	.long	13
	.long	1505                            # BTF_KIND_FWD(id = 30)
	.long	117440512                       # 0x7000000
	.long	0
	.long	1519                            # BTF_KIND_FWD(id = 31)
	.long	117440512                       # 0x7000000
	.long	0
	.byte	0                               # string offset=0
	.ascii	"int"                           # string offset=1
	.byte	0
	.ascii	"__ARRAY_SIZE_TYPE__"           # string offset=5
	.byte	0
	.ascii	"type"                          # string offset=25
	.byte	0
	.ascii	"max_entries"                   # string offset=30
	.byte	0
	.ascii	"rb"                            # string offset=42
	.byte	0
	.ascii	"__sk_buff"                     # string offset=45
	.byte	0
	.ascii	"len"                           # string offset=55
	.byte	0
	.ascii	"pkt_type"                      # string offset=59
	.byte	0
	.ascii	"mark"                          # string offset=68
	.byte	0
	.ascii	"queue_mapping"                 # string offset=73
	.byte	0
	.ascii	"protocol"                      # string offset=87
	.byte	0
	.ascii	"vlan_present"                  # string offset=96
	.byte	0
	.ascii	"vlan_tci"                      # string offset=109
	.byte	0
	.ascii	"vlan_proto"                    # string offset=118
	.byte	0
	.ascii	"priority"                      # string offset=129
	.byte	0
	.ascii	"ingress_ifindex"               # string offset=138
	.byte	0
	.ascii	"ifindex"                       # string offset=154
	.byte	0
	.ascii	"tc_index"                      # string offset=162
	.byte	0
	.ascii	"cb"                            # string offset=171
	.byte	0
	.ascii	"hash"                          # string offset=174
	.byte	0
	.ascii	"tc_classid"                    # string offset=179
	.byte	0
	.ascii	"data"                          # string offset=190
	.byte	0
	.ascii	"data_end"                      # string offset=195
	.byte	0
	.ascii	"napi_id"                       # string offset=204
	.byte	0
	.ascii	"family"                        # string offset=212
	.byte	0
	.ascii	"remote_ip4"                    # string offset=219
	.byte	0
	.ascii	"local_ip4"                     # string offset=230
	.byte	0
	.ascii	"remote_ip6"                    # string offset=240
	.byte	0
	.ascii	"local_ip6"                     # string offset=251
	.byte	0
	.ascii	"remote_port"                   # string offset=261
	.byte	0
	.ascii	"local_port"                    # string offset=273
	.byte	0
	.ascii	"data_meta"                     # string offset=284
	.byte	0
	.ascii	"tstamp"                        # string offset=294
	.byte	0
	.ascii	"wire_len"                      # string offset=301
	.byte	0
	.ascii	"gso_segs"                      # string offset=310
	.byte	0
	.ascii	"gso_size"                      # string offset=319
	.byte	0
	.ascii	"tstamp_type"                   # string offset=328
	.byte	0
	.ascii	"hwtstamp"                      # string offset=340
	.byte	0
	.ascii	"__u32"                         # string offset=349
	.byte	0
	.ascii	"unsigned int"                  # string offset=355
	.byte	0
	.ascii	"flow_keys"                     # string offset=368
	.byte	0
	.ascii	"__u64"                         # string offset=378
	.byte	0
	.ascii	"unsigned long long"            # string offset=384
	.byte	0
	.ascii	"sk"                            # string offset=403
	.byte	0
	.ascii	"__u8"                          # string offset=406
	.byte	0
	.ascii	"unsigned char"                 # string offset=411
	.byte	0
	.ascii	"skb"                           # string offset=425
	.byte	0
	.ascii	"socket_handler"                # string offset=429
	.byte	0
	.ascii	"socket"                        # string offset=444
	.byte	0
	.ascii	"/home/luis/Documents/desk/proj/spectector-bpf/spectector/tests/bpf/external-samples/libbpf-bootstrap/examples/c/sockfilter.bpf.c" # string offset=451
	.byte	0
	.ascii	"int socket_handler(struct __sk_buff *skb)" # string offset=580
	.byte	0
	.ascii	"\tbpf_skb_load_bytes(skb, 12, &proto, 2);" # string offset=622
	.byte	0
	.ascii	"\tproto = __bpf_ntohs(proto);" # string offset=663
	.byte	0
	.ascii	"\tif (proto != ETH_P_IP)"      # string offset=692
	.byte	0
	.ascii	"\tbpf_skb_load_bytes(skb, nhoff + offsetof(struct iphdr, frag_off), &frag_off, 2);" # string offset=716
	.byte	0
	.ascii	"\tfrag_off = __bpf_ntohs(frag_off);" # string offset=798
	.byte	0
	.ascii	"\treturn frag_off & (IP_MF | IP_OFFSET);" # string offset=833
	.byte	0
	.ascii	"\tif (ip_is_fragment(skb, nhoff))" # string offset=873
	.byte	0
	.ascii	"\te = bpf_ringbuf_reserve(&rb, sizeof(*e), 0);" # string offset=906
	.byte	0
	.ascii	"\tif (!e)"                     # string offset=952
	.byte	0
	.ascii	"\tbpf_skb_load_bytes(skb, nhoff + offsetof(struct iphdr, protocol), &e->ip_proto, 1);" # string offset=961
	.byte	0
	.ascii	"\tif (e->ip_proto != IPPROTO_GRE) {" # string offset=1046
	.byte	0
	.ascii	"\t\tbpf_skb_load_bytes(skb, nhoff + offsetof(struct iphdr, saddr), &(e->src_addr), 4);" # string offset=1081
	.byte	0
	.ascii	"\t\tbpf_skb_load_bytes(skb, nhoff + offsetof(struct iphdr, daddr), &(e->dst_addr), 4);" # string offset=1166
	.byte	0
	.ascii	"\tbpf_skb_load_bytes(skb, nhoff + 0, &verlen, 1);" # string offset=1251
	.byte	0
	.ascii	"\tbpf_skb_load_bytes(skb, nhoff + ((verlen & 0xF) << 2), &(e->ports), 4);" # string offset=1300
	.byte	0
	.ascii	"\te->pkt_type = skb->pkt_type;" # string offset=1373
	.byte	0
	.ascii	"\te->ifindex = skb->ifindex;"  # string offset=1403
	.byte	0
	.ascii	"\tbpf_ringbuf_submit(e, 0);"   # string offset=1431
	.byte	0
	.ascii	"\treturn skb->len;"            # string offset=1458
	.byte	0
	.byte	125                             # string offset=1476
	.byte	0
	.ascii	"char"                          # string offset=1478
	.byte	0
	.ascii	"LICENSE"                       # string offset=1483
	.byte	0
	.ascii	".maps"                         # string offset=1491
	.byte	0
	.ascii	"license"                       # string offset=1497
	.byte	0
	.ascii	"bpf_flow_keys"                 # string offset=1505
	.byte	0
	.ascii	"bpf_sock"                      # string offset=1519
	.byte	0
	.section	.BTF.ext,"",@progbits
	.short	60319                           # 0xeb9f
	.byte	1
	.byte	0
	.long	32
	.long	0
	.long	20
	.long	20
	.long	556
	.long	576
	.long	0
	.long	8                               # FuncInfo
	.long	444                             # FuncInfo section string offset=444
	.long	1
	.long	.Lfunc_begin0
	.long	24
	.long	16                              # LineInfo
	.long	444                             # LineInfo section string offset=444
	.long	34
	.long	.Lfunc_begin0
	.long	451
	.long	580
	.long	32768                           # Line 32 Col 0
	.long	.Ltmp4
	.long	451
	.long	0
	.long	0                               # Line 0 Col 0
	.long	.Ltmp5
	.long	451
	.long	622
	.long	39938                           # Line 39 Col 2
	.long	.Ltmp7
	.long	451
	.long	663
	.long	40970                           # Line 40 Col 10
	.long	.Ltmp12
	.long	451
	.long	663
	.long	40968                           # Line 40 Col 8
	.long	.Ltmp13
	.long	451
	.long	692
	.long	41990                           # Line 41 Col 6
	.long	.Ltmp18
	.long	451
	.long	0
	.long	0                               # Line 0 Col 0
	.long	.Ltmp19
	.long	451
	.long	716
	.long	26626                           # Line 26 Col 2
	.long	.Ltmp23
	.long	451
	.long	798
	.long	27661                           # Line 27 Col 13
	.long	.Ltmp26
	.long	451
	.long	833
	.long	28690                           # Line 28 Col 18
	.long	.Ltmp29
	.long	451
	.long	873
	.long	45062                           # Line 44 Col 6
	.long	.Ltmp32
	.long	451
	.long	906
	.long	49158                           # Line 48 Col 6
	.long	.Ltmp36
	.long	451
	.long	952
	.long	50182                           # Line 49 Col 6
	.long	.Ltmp39
	.long	451
	.long	961
	.long	53320                           # Line 52 Col 72
	.long	.Ltmp40
	.long	451
	.long	961
	.long	53250                           # Line 52 Col 2
	.long	.Ltmp43
	.long	451
	.long	1046
	.long	55305                           # Line 54 Col 9
	.long	.Ltmp46
	.long	451
	.long	1046
	.long	55302                           # Line 54 Col 6
	.long	.Ltmp49
	.long	451
	.long	1081
	.long	56323                           # Line 55 Col 3
	.long	.Ltmp51
	.long	451
	.long	1166
	.long	57415                           # Line 56 Col 71
	.long	.Ltmp52
	.long	451
	.long	1166
	.long	57347                           # Line 56 Col 3
	.long	.Ltmp55
	.long	451
	.long	0
	.long	0                               # Line 0 Col 0
	.long	.Ltmp56
	.long	451
	.long	1251
	.long	60418                           # Line 59 Col 2
	.long	.Ltmp58
	.long	451
	.long	1300
	.long	61476                           # Line 60 Col 36
	.long	.Ltmp61
	.long	451
	.long	1300
	.long	61490                           # Line 60 Col 50
	.long	.Ltmp64
	.long	451
	.long	1300
	.long	61472                           # Line 60 Col 32
	.long	.Ltmp65
	.long	451
	.long	1300
	.long	61502                           # Line 60 Col 62
	.long	.Ltmp66
	.long	451
	.long	1300
	.long	61442                           # Line 60 Col 2
	.long	.Ltmp68
	.long	451
	.long	1373
	.long	62485                           # Line 61 Col 21
	.long	.Ltmp69
	.long	451
	.long	1373
	.long	62478                           # Line 61 Col 14
	.long	.Ltmp70
	.long	451
	.long	1403
	.long	63508                           # Line 62 Col 20
	.long	.Ltmp71
	.long	451
	.long	1403
	.long	63501                           # Line 62 Col 13
	.long	.Ltmp72
	.long	451
	.long	1431
	.long	64514                           # Line 63 Col 2
	.long	.Ltmp74
	.long	451
	.long	1458
	.long	66574                           # Line 65 Col 14
	.long	.Ltmp77
	.long	451
	.long	1476
	.long	67585                           # Line 66 Col 1
	.addrsig
	.addrsig_sym socket_handler
	.addrsig_sym LICENSE
	.addrsig_sym rb
	.section	.debug_line,"",@progbits
.Lline_table_start0:

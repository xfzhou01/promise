; ModuleID = '/home/x/xiaofeng-zhou/promise/experiments/vitis2020_examples/machsuite/backprop/aes/solution1/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%struct.ap_fixed = type { %struct.ap_fixed_base }
%struct.ap_fixed_base = type { %struct.ssdm_int }
%struct.ssdm_int = type { i32 }

; Function Attrs: noinline
define void @apatb_backprop_top_ir(%struct.ap_fixed* %weights1, %struct.ap_fixed* %weights2, %struct.ap_fixed* %weights3, %struct.ap_fixed* %biases1, %struct.ap_fixed* %biases2, %struct.ap_fixed* %biases3, %struct.ap_fixed* %training_data, %struct.ap_fixed* %training_targets) local_unnamed_addr #0 {
entry:
  %weights1_copy = alloca [832 x %struct.ap_fixed], align 512
  %malloccall = tail call i8* @malloc(i64 16384)
  %weights2_copy = bitcast i8* %malloccall to [4096 x %struct.ap_fixed]*
  %weights3_copy = alloca [192 x %struct.ap_fixed], align 512
  %biases1_copy = alloca [64 x %struct.ap_fixed], align 512
  %biases2_copy = alloca [64 x %struct.ap_fixed], align 512
  %biases3_copy = alloca [3 x %struct.ap_fixed], align 512
  %malloccall1 = tail call i8* @malloc(i64 8476)
  %training_data_copy = bitcast i8* %malloccall1 to [2119 x %struct.ap_fixed]*
  %training_targets_copy = alloca [489 x %struct.ap_fixed], align 512
  %0 = bitcast %struct.ap_fixed* %weights1 to [832 x %struct.ap_fixed]*
  %1 = bitcast %struct.ap_fixed* %weights2 to [4096 x %struct.ap_fixed]*
  %2 = bitcast %struct.ap_fixed* %weights3 to [192 x %struct.ap_fixed]*
  %3 = bitcast %struct.ap_fixed* %biases1 to [64 x %struct.ap_fixed]*
  %4 = bitcast %struct.ap_fixed* %biases2 to [64 x %struct.ap_fixed]*
  %5 = bitcast %struct.ap_fixed* %biases3 to [3 x %struct.ap_fixed]*
  %6 = bitcast %struct.ap_fixed* %training_data to [2119 x %struct.ap_fixed]*
  %7 = bitcast %struct.ap_fixed* %training_targets to [489 x %struct.ap_fixed]*
  call fastcc void @copy_in([832 x %struct.ap_fixed]* %0, [832 x %struct.ap_fixed]* nonnull align 512 %weights1_copy, [4096 x %struct.ap_fixed]* %1, [4096 x %struct.ap_fixed]* %weights2_copy, [192 x %struct.ap_fixed]* %2, [192 x %struct.ap_fixed]* nonnull align 512 %weights3_copy, [64 x %struct.ap_fixed]* %3, [64 x %struct.ap_fixed]* nonnull align 512 %biases1_copy, [64 x %struct.ap_fixed]* %4, [64 x %struct.ap_fixed]* nonnull align 512 %biases2_copy, [3 x %struct.ap_fixed]* %5, [3 x %struct.ap_fixed]* nonnull align 512 %biases3_copy, [2119 x %struct.ap_fixed]* %6, [2119 x %struct.ap_fixed]* %training_data_copy, [489 x %struct.ap_fixed]* %7, [489 x %struct.ap_fixed]* nonnull align 512 %training_targets_copy)
  %8 = getelementptr inbounds [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %weights1_copy, i32 0, i32 0
  %9 = getelementptr inbounds [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %weights2_copy, i32 0, i32 0
  %10 = getelementptr inbounds [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %weights3_copy, i32 0, i32 0
  %11 = getelementptr inbounds [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %biases1_copy, i32 0, i32 0
  %12 = getelementptr inbounds [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %biases2_copy, i32 0, i32 0
  %13 = getelementptr inbounds [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %biases3_copy, i32 0, i32 0
  %14 = getelementptr inbounds [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %training_data_copy, i32 0, i32 0
  %15 = getelementptr inbounds [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %training_targets_copy, i32 0, i32 0
  call void @apatb_backprop_top_hw(%struct.ap_fixed* %8, %struct.ap_fixed* %9, %struct.ap_fixed* %10, %struct.ap_fixed* %11, %struct.ap_fixed* %12, %struct.ap_fixed* %13, %struct.ap_fixed* %14, %struct.ap_fixed* %15)
  call fastcc void @copy_out([832 x %struct.ap_fixed]* %0, [832 x %struct.ap_fixed]* nonnull align 512 %weights1_copy, [4096 x %struct.ap_fixed]* %1, [4096 x %struct.ap_fixed]* %weights2_copy, [192 x %struct.ap_fixed]* %2, [192 x %struct.ap_fixed]* nonnull align 512 %weights3_copy, [64 x %struct.ap_fixed]* %3, [64 x %struct.ap_fixed]* nonnull align 512 %biases1_copy, [64 x %struct.ap_fixed]* %4, [64 x %struct.ap_fixed]* nonnull align 512 %biases2_copy, [3 x %struct.ap_fixed]* %5, [3 x %struct.ap_fixed]* nonnull align 512 %biases3_copy, [2119 x %struct.ap_fixed]* %6, [2119 x %struct.ap_fixed]* %training_data_copy, [489 x %struct.ap_fixed]* %7, [489 x %struct.ap_fixed]* nonnull align 512 %training_targets_copy)
  tail call void @free(i8* %malloccall)
  tail call void @free(i8* %malloccall1)
  ret void
}

declare noalias i8* @malloc(i64) local_unnamed_addr

; Function Attrs: noinline
define internal fastcc void @copy_in([832 x %struct.ap_fixed]*, [832 x %struct.ap_fixed]* noalias align 512, [4096 x %struct.ap_fixed]*, [4096 x %struct.ap_fixed]* noalias, [192 x %struct.ap_fixed]*, [192 x %struct.ap_fixed]* noalias align 512, [64 x %struct.ap_fixed]*, [64 x %struct.ap_fixed]* noalias align 512, [64 x %struct.ap_fixed]*, [64 x %struct.ap_fixed]* noalias align 512, [3 x %struct.ap_fixed]*, [3 x %struct.ap_fixed]* noalias align 512, [2119 x %struct.ap_fixed]*, [2119 x %struct.ap_fixed]* noalias, [489 x %struct.ap_fixed]*, [489 x %struct.ap_fixed]* noalias align 512) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0a832struct.ap_fixed([832 x %struct.ap_fixed]* align 512 %1, [832 x %struct.ap_fixed]* %0)
  call fastcc void @onebyonecpy_hls.p0a4096struct.ap_fixed([4096 x %struct.ap_fixed]* %3, [4096 x %struct.ap_fixed]* %2)
  call fastcc void @onebyonecpy_hls.p0a192struct.ap_fixed([192 x %struct.ap_fixed]* align 512 %5, [192 x %struct.ap_fixed]* %4)
  call fastcc void @onebyonecpy_hls.p0a64struct.ap_fixed([64 x %struct.ap_fixed]* align 512 %7, [64 x %struct.ap_fixed]* %6)
  call fastcc void @onebyonecpy_hls.p0a64struct.ap_fixed([64 x %struct.ap_fixed]* align 512 %9, [64 x %struct.ap_fixed]* %8)
  call fastcc void @onebyonecpy_hls.p0a3struct.ap_fixed([3 x %struct.ap_fixed]* align 512 %11, [3 x %struct.ap_fixed]* %10)
  call fastcc void @onebyonecpy_hls.p0a2119struct.ap_fixed([2119 x %struct.ap_fixed]* %13, [2119 x %struct.ap_fixed]* %12)
  call fastcc void @onebyonecpy_hls.p0a489struct.ap_fixed([489 x %struct.ap_fixed]* align 512 %15, [489 x %struct.ap_fixed]* %14)
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a832struct.ap_fixed([832 x %struct.ap_fixed]* noalias align 512, [832 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [832 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [832 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [832 x %struct.ap_fixed], [832 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 832
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

declare i1 @fpga_fifo_exist_4(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* noalias nocapture, %struct.ap_fixed* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_fixed
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_fixed* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_4(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_fixed* %2 to i8*
  %6 = bitcast %struct.ap_fixed* %1 to i8*
  call void @fpga_fifo_pop_4(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_fixed, %struct.ap_fixed* %2
  %8 = bitcast %struct.ap_fixed* %2 to i8*
  %9 = bitcast %struct.ap_fixed* %0 to i8*
  call void @fpga_fifo_push_4(i8* %8, i8* %9)
  br label %empty, !llvm.loop !5

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_fixed* %1 to i8*
  %11 = bitcast %struct.ap_fixed* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 4, i1 false)
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #4

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* noalias nocapture, %struct.ap_fixed_base* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_fixed_base
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_fixed_base* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_4(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_fixed_base* %2 to i8*
  %6 = bitcast %struct.ap_fixed_base* %1 to i8*
  call void @fpga_fifo_pop_4(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_fixed_base, %struct.ap_fixed_base* %2
  %8 = bitcast %struct.ap_fixed_base* %2 to i8*
  %9 = bitcast %struct.ap_fixed_base* %0 to i8*
  call void @fpga_fifo_push_4(i8* %8, i8* %9)
  br label %empty, !llvm.loop !7

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_fixed_base* %1 to i8*
  %11 = bitcast %struct.ap_fixed_base* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 4, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* noalias nocapture, %struct.ssdm_int* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ssdm_int
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ssdm_int* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_4(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ssdm_int* %2 to i8*
  %6 = bitcast %struct.ssdm_int* %1 to i8*
  call void @fpga_fifo_pop_4(i8* %5, i8* %6)
  %7 = load volatile %struct.ssdm_int, %struct.ssdm_int* %2
  %8 = bitcast %struct.ssdm_int* %2 to i8*
  %9 = bitcast %struct.ssdm_int* %0 to i8*
  call void @fpga_fifo_push_4(i8* %8, i8* %9)
  br label %empty, !llvm.loop !8

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ssdm_int* %1 to i8*
  %11 = bitcast %struct.ssdm_int* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 4, i1 false)
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a4096struct.ap_fixed([4096 x %struct.ap_fixed]* noalias, [4096 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [4096 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [4096 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [4096 x %struct.ap_fixed], [4096 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 4096
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a192struct.ap_fixed([192 x %struct.ap_fixed]* noalias align 512, [192 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [192 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [192 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [192 x %struct.ap_fixed], [192 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 192
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a64struct.ap_fixed([64 x %struct.ap_fixed]* noalias align 512, [64 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [64 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [64 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [64 x %struct.ap_fixed], [64 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 64
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a3struct.ap_fixed([3 x %struct.ap_fixed]* noalias align 512, [3 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [3 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [3 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [3 x %struct.ap_fixed], [3 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 3
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a2119struct.ap_fixed([2119 x %struct.ap_fixed]* noalias, [2119 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [2119 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [2119 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [2119 x %struct.ap_fixed], [2119 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 2119
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0a489struct.ap_fixed([489 x %struct.ap_fixed]* noalias align 512, [489 x %struct.ap_fixed]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [489 x %struct.ap_fixed]* %0, null
  %3 = icmp eq [489 x %struct.ap_fixed]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx9 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9
  %src.addr = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9
  %5 = bitcast %struct.ap_fixed* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_4(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @streamcpy_hls.p0struct.ap_fixed(%struct.ap_fixed* %dst.addr, %struct.ap_fixed* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.01 = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0
  %dst.addr.02 = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0
  %9 = bitcast %struct.ap_fixed_base* %src.addr.01 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_fixed_base(%struct.ap_fixed_base* %dst.addr.02, %struct.ap_fixed_base* %src.addr.01)
  br label %for.loop.head

; <label>:12:                                     ; preds = %8
  %src.addr.0.03 = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0
  %13 = bitcast %struct.ssdm_int* %src.addr.0.03 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.04, %struct.ssdm_int* %src.addr.0.03)
  br label %for.loop.head

; <label>:16:                                     ; preds = %12
  %dst.addr.0.0.06.gep7 = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %0, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %17 = bitcast i32* %dst.addr.0.0.06.gep7 to i8*
  %src.addr.0.0.05.gep8 = getelementptr [489 x %struct.ap_fixed], [489 x %struct.ap_fixed]* %1, i64 0, i64 %for.loop.idx9, i32 0, i32 0, i32 0
  %18 = bitcast i32* %src.addr.0.0.05.gep8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %17, i8* align 1 %18, i64 4, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %16, %15, %11, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx9, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 489
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

; Function Attrs: noinline
define internal fastcc void @copy_out([832 x %struct.ap_fixed]*, [832 x %struct.ap_fixed]* noalias align 512, [4096 x %struct.ap_fixed]*, [4096 x %struct.ap_fixed]* noalias, [192 x %struct.ap_fixed]*, [192 x %struct.ap_fixed]* noalias align 512, [64 x %struct.ap_fixed]*, [64 x %struct.ap_fixed]* noalias align 512, [64 x %struct.ap_fixed]*, [64 x %struct.ap_fixed]* noalias align 512, [3 x %struct.ap_fixed]*, [3 x %struct.ap_fixed]* noalias align 512, [2119 x %struct.ap_fixed]*, [2119 x %struct.ap_fixed]* noalias, [489 x %struct.ap_fixed]*, [489 x %struct.ap_fixed]* noalias align 512) unnamed_addr #5 {
entry:
  call fastcc void @onebyonecpy_hls.p0a832struct.ap_fixed([832 x %struct.ap_fixed]* %0, [832 x %struct.ap_fixed]* align 512 %1)
  call fastcc void @onebyonecpy_hls.p0a4096struct.ap_fixed([4096 x %struct.ap_fixed]* %2, [4096 x %struct.ap_fixed]* %3)
  call fastcc void @onebyonecpy_hls.p0a192struct.ap_fixed([192 x %struct.ap_fixed]* %4, [192 x %struct.ap_fixed]* align 512 %5)
  call fastcc void @onebyonecpy_hls.p0a64struct.ap_fixed([64 x %struct.ap_fixed]* %6, [64 x %struct.ap_fixed]* align 512 %7)
  call fastcc void @onebyonecpy_hls.p0a64struct.ap_fixed([64 x %struct.ap_fixed]* %8, [64 x %struct.ap_fixed]* align 512 %9)
  call fastcc void @onebyonecpy_hls.p0a3struct.ap_fixed([3 x %struct.ap_fixed]* %10, [3 x %struct.ap_fixed]* align 512 %11)
  call fastcc void @onebyonecpy_hls.p0a2119struct.ap_fixed([2119 x %struct.ap_fixed]* %12, [2119 x %struct.ap_fixed]* %13)
  call fastcc void @onebyonecpy_hls.p0a489struct.ap_fixed([489 x %struct.ap_fixed]* %14, [489 x %struct.ap_fixed]* align 512 %15)
  ret void
}

declare void @free(i8*) local_unnamed_addr

declare void @apatb_backprop_top_hw(%struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*)

define void @backprop_top_hw_stub_wrapper(%struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*) #6 {
entry:
  %8 = bitcast %struct.ap_fixed* %0 to [832 x %struct.ap_fixed]*
  %9 = bitcast %struct.ap_fixed* %1 to [4096 x %struct.ap_fixed]*
  %10 = bitcast %struct.ap_fixed* %2 to [192 x %struct.ap_fixed]*
  %11 = bitcast %struct.ap_fixed* %3 to [64 x %struct.ap_fixed]*
  %12 = bitcast %struct.ap_fixed* %4 to [64 x %struct.ap_fixed]*
  %13 = bitcast %struct.ap_fixed* %5 to [3 x %struct.ap_fixed]*
  %14 = bitcast %struct.ap_fixed* %6 to [2119 x %struct.ap_fixed]*
  %15 = bitcast %struct.ap_fixed* %7 to [489 x %struct.ap_fixed]*
  call void @copy_out([832 x %struct.ap_fixed]* null, [832 x %struct.ap_fixed]* %8, [4096 x %struct.ap_fixed]* null, [4096 x %struct.ap_fixed]* %9, [192 x %struct.ap_fixed]* null, [192 x %struct.ap_fixed]* %10, [64 x %struct.ap_fixed]* null, [64 x %struct.ap_fixed]* %11, [64 x %struct.ap_fixed]* null, [64 x %struct.ap_fixed]* %12, [3 x %struct.ap_fixed]* null, [3 x %struct.ap_fixed]* %13, [2119 x %struct.ap_fixed]* null, [2119 x %struct.ap_fixed]* %14, [489 x %struct.ap_fixed]* null, [489 x %struct.ap_fixed]* %15)
  %16 = bitcast [832 x %struct.ap_fixed]* %8 to %struct.ap_fixed*
  %17 = bitcast [4096 x %struct.ap_fixed]* %9 to %struct.ap_fixed*
  %18 = bitcast [192 x %struct.ap_fixed]* %10 to %struct.ap_fixed*
  %19 = bitcast [64 x %struct.ap_fixed]* %11 to %struct.ap_fixed*
  %20 = bitcast [64 x %struct.ap_fixed]* %12 to %struct.ap_fixed*
  %21 = bitcast [3 x %struct.ap_fixed]* %13 to %struct.ap_fixed*
  %22 = bitcast [2119 x %struct.ap_fixed]* %14 to %struct.ap_fixed*
  %23 = bitcast [489 x %struct.ap_fixed]* %15 to %struct.ap_fixed*
  call void @backprop_top_hw_stub(%struct.ap_fixed* %16, %struct.ap_fixed* %17, %struct.ap_fixed* %18, %struct.ap_fixed* %19, %struct.ap_fixed* %20, %struct.ap_fixed* %21, %struct.ap_fixed* %22, %struct.ap_fixed* %23)
  call void @copy_in([832 x %struct.ap_fixed]* null, [832 x %struct.ap_fixed]* %8, [4096 x %struct.ap_fixed]* null, [4096 x %struct.ap_fixed]* %9, [192 x %struct.ap_fixed]* null, [192 x %struct.ap_fixed]* %10, [64 x %struct.ap_fixed]* null, [64 x %struct.ap_fixed]* %11, [64 x %struct.ap_fixed]* null, [64 x %struct.ap_fixed]* %12, [3 x %struct.ap_fixed]* null, [3 x %struct.ap_fixed]* %13, [2119 x %struct.ap_fixed]* null, [2119 x %struct.ap_fixed]* %14, [489 x %struct.ap_fixed]* null, [489 x %struct.ap_fixed]* %15)
  ret void
}

declare void @backprop_top_hw_stub(%struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*, %struct.ap_fixed*)

declare i1 @fpga_fifo_not_empty_4(i8*)

declare void @fpga_fifo_pop_4(i8*, i8*)

declare void @fpga_fifo_push_4(i8*, i8*)

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { noinline "fpga.wrapper.func"="copyin" }
attributes #2 = { noinline "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline "fpga.wrapper.func"="streamcpy_hls" }
attributes #4 = { argmemonly nounwind }
attributes #5 = { noinline "fpga.wrapper.func"="copyout" }
attributes #6 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.rotate.disable"}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}

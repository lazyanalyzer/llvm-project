; REQUIRES: asserts
; RUN: opt -mattr=+neon -passes=loop-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=NEON-NO-VECLIB
; RUN: opt -mattr=+sve -passes=loop-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=SVE-NO-VECLIB
; RUN: opt -mattr=+neon -vector-library=ArmPL -passes=loop-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=NEON-ARMPL
; RUN: opt -mattr=+neon -vector-library=sleefgnuabi -passes=loop-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=NEON-SLEEF
; RUN: opt -mattr=+sve -vector-library=ArmPL -passes=loop-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=SVE-ARMPL
; RUN: opt -mattr=+sve -vector-library=sleefgnuabi -passes=loop-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=SVE-SLEEF
; RUN: opt -mattr=+sve -vector-library=ArmPL -passes=loop-vectorize -prefer-predicate-over-epilogue=predicate-dont-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=SVE-ARMPL-TAILFOLD
; RUN: opt -mattr=+sve -vector-library=sleefgnuabi -passes=loop-vectorize -prefer-predicate-over-epilogue=predicate-dont-vectorize -debug-only=loop-vectorize -disable-output -S < %s 2>&1 | FileCheck %s --check-prefix=SVE-SLEEF-TAILFOLD

target triple = "aarch64-unknown-linux-gnu"

define void @frem_f64(ptr noalias %in.ptr, ptr noalias %out.ptr) {
; NEON-NO-VECLIB-LABEL: 'frem_f64'
; NEON-NO-VECLIB:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; NEON-NO-VECLIB:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-NO-VECLIB-LABEL: 'frem_f64'
; SVE-NO-VECLIB:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; SVE-NO-VECLIB:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-NO-VECLIB:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-NO-VECLIB:  Cost of Invalid for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; NEON-ARMPL-LABEL: 'frem_f64'
; NEON-ARMPL:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; NEON-ARMPL:  Cost of 10 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; NEON-SLEEF-LABEL: 'frem_f64'
; NEON-SLEEF:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; NEON-SLEEF:  Cost of 10 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-ARMPL-LABEL: 'frem_f64'
; SVE-ARMPL:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; SVE-ARMPL:  Cost of 10 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL:  Cost of 10 for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-SLEEF-LABEL: 'frem_f64'
; SVE-SLEEF:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; SVE-SLEEF:  Cost of 10 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF:  Cost of 10 for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-ARMPL-TAILFOLD-LABEL: 'frem_f64'
; SVE-ARMPL-TAILFOLD:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; SVE-ARMPL-TAILFOLD:  Cost of 10 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL-TAILFOLD:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL-TAILFOLD:  Cost of 10 for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-SLEEF-TAILFOLD-LABEL: 'frem_f64'
; SVE-SLEEF-TAILFOLD:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem double %in, %in
; SVE-SLEEF-TAILFOLD:  Cost of 10 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF-TAILFOLD:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF-TAILFOLD:  Cost of 10 for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
  entry:
  br label %for.body

  for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %in.gep = getelementptr inbounds double, ptr %in.ptr, i64 %iv
  %in = load double, ptr %in.gep, align 8
  %res = frem double %in, %in
  %out.gep = getelementptr inbounds double, ptr %out.ptr, i64 %iv
  store double %res, ptr %out.gep, align 8
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond = icmp eq i64 %iv.next, 1000
  br i1 %exitcond, label %for.end, label %for.body

  for.end:
  ret void
}

define void @frem_f32(ptr noalias %in.ptr, ptr noalias %out.ptr) {
; NEON-NO-VECLIB-LABEL: 'frem_f32'
; NEON-NO-VECLIB:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; NEON-NO-VECLIB:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; NEON-NO-VECLIB:  Cost of 52 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-NO-VECLIB-LABEL: 'frem_f32'
; SVE-NO-VECLIB:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; SVE-NO-VECLIB:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-NO-VECLIB:  Cost of 52 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-NO-VECLIB:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-NO-VECLIB:  Cost of Invalid for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-NO-VECLIB:  Cost of Invalid for VF vscale x 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; NEON-ARMPL-LABEL: 'frem_f32'
; NEON-ARMPL:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; NEON-ARMPL:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; NEON-ARMPL:  Cost of 10 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; NEON-SLEEF-LABEL: 'frem_f32'
; NEON-SLEEF:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; NEON-SLEEF:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; NEON-SLEEF:  Cost of 10 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-ARMPL-LABEL: 'frem_f32'
; SVE-ARMPL:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; SVE-ARMPL:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL:  Cost of 10 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL:  Cost of Invalid for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL:  Cost of 10 for VF vscale x 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-SLEEF-LABEL: 'frem_f32'
; SVE-SLEEF:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; SVE-SLEEF:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF:  Cost of 10 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF:  Cost of Invalid for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF:  Cost of 10 for VF vscale x 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-ARMPL-TAILFOLD-LABEL: 'frem_f32'
; SVE-ARMPL-TAILFOLD:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; SVE-ARMPL-TAILFOLD:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL-TAILFOLD:  Cost of 10 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL-TAILFOLD:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL-TAILFOLD:  Cost of Invalid for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-ARMPL-TAILFOLD:  Cost of 10 for VF vscale x 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
; SVE-SLEEF-TAILFOLD-LABEL: 'frem_f32'
; SVE-SLEEF-TAILFOLD:  LV: Found an estimated cost of 10 for VF 1 For instruction: %res = frem float %in, %in
; SVE-SLEEF-TAILFOLD:  Cost of 24 for VF 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF-TAILFOLD:  Cost of 10 for VF 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF-TAILFOLD:  Cost of Invalid for VF vscale x 1: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF-TAILFOLD:  Cost of Invalid for VF vscale x 2: WIDEN ir<%res> = frem ir<%in>, ir<%in>
; SVE-SLEEF-TAILFOLD:  Cost of 10 for VF vscale x 4: WIDEN ir<%res> = frem ir<%in>, ir<%in>
;
  entry:
  br label %for.body

  for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %in.gep = getelementptr inbounds float, ptr %in.ptr, i64 %iv
  %in = load float, ptr %in.gep, align 8
  %res = frem float %in, %in
  %out.gep = getelementptr inbounds float, ptr %out.ptr, i64 %iv
  store float %res, ptr %out.gep, align 4
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond = icmp eq i64 %iv.next, 1000
  br i1 %exitcond, label %for.end, label %for.body

  for.end:
  ret void
}

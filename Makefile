#=======================================================================
#  Compiler options
#=======================================================================
FC = h5pfc -fpp # ifort preprocessor
# FC = h5pfc -cpp # gfortran preprocessor
## Laptop
FC += -r8 -O3 # ifort options
# FC += -fdefault-real-8 -fdefault-double-8 -O2 # gfortran options
#FC += -fdefault-real-8 -fdefault-double-8 -O0 -g -fbacktrace -fbounds-check
## Cartesius
# FC += -r8 -O3 -xAVX -axCORE-AVX2
## Irene
# FC += -r8 -O3 -mavx2 $(FFTW3_FFLAGS)
## MareNostrum
# FC += -r8 -O3 $(FFTW_FFLAGS)
## Traceback / Debug
# FC += -r8 -O0 -g -traceback -check bounds 
# FC += -DSHM -DSHM_DEBUG

#=======================================================================
#  Library
#======================================================================
# Common build flags
##  Laptop (with intel libraries)
LDFLAGS = -lfftw3 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lhdf5_fortran -lhdf5 -lsz -lz -ldl -lm
## Laptop (with GNU libraries)
# LDFLAGS = -lfftw3 -llapack -lblas -lpthread -lhdf5_fortran -lhdf5 -lsz -lz -ldl -lm

## Cartesius (Before compiling, load modules 2019 intel/2018b HDF5 FFTW)
# FFTW3_LIBS = -lfftw3
# BLAS_LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread
# HDF5_LIBS = -lhdf5_fortran -lhdf5 -lz -ldl -lm
# LDFLAGS = $(FFTW3_LIBS) $(BLAS_LIBS) $(HDF5_LIBS)

## Irene (Before compiling, load modules flavor/hdf5/parallel hdf5 fftw3/gnu)
# FFTW3_LIBS = $(FFTW3_LDFLAGS)
# BLAS_LIBS = $(MKL_LDFLAGS)
# HDF5_LIBS = -lhdf5_fortran -lhdf5 -lz -ldl -lm
# LDFLAGS = $(FFTW3_LIBS) $(BLAS_LIBS) $(HDF5_LIBS)

## MareNostrum (Before compiling, load modules fftw hdf5)
# FFTW3_LIBS = $(FFTW_LIBS)
# BLAS_LIBS = -L$(MKLROOT)/lib/intel64 -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread
# HDF5_LIBS = -lhdf5_fortran -lhdf5  -lsz -lz -ldl -lm
# LDFLAGS = $(FFTW3_LIBS) $(BLAS_LIBS) $(HDF5_LIBS)

## SuperMUC-NG (Before compiling, load modules fftw hdf5 szip)
# BLAS_LIBS = $(MKL_LIB)
# FFTW3_LIBS = $(FFTW_LIB)
# HDF5_LIBS = $(HDF5_F90_SHLIB) $(HDF5_SHLIB) -L$(SZIP_LIBDIR) -lz -ldl -lm
# LDFLAGS = $(BLAS_LIBS) $(FFTW3_LIBS) $(HDF5_LIBS)

#=======================================================================
#  Non-module Fortran files to be compiled:
#=======================================================================
EXTRA_DIST = transpose_z_to_x.F90 transpose_x_to_z.F90 transpose_x_to_y.F90\
	     transpose_y_to_x.F90 transpose_y_to_z.F90 transpose_z_to_y.F90\
	     factor.F90 halo.F90 fft_common.F90 alloc.F90 halo_common.F90

FFILES += CalcDissipationNu.F90 CalcMaxCFL.F90 CalcPlateNu.F90\
	  CalcLocalDivergence.F90 CheckDivergence.F90 CorrectPressure.F90\
          CorrectVelocity.F90 CreateGrid.F90 CreateInitialConditions.F90\
	  DeallocateVariables.F90 DebugRoutines.F90\
	  ExplicitTermsTemp.F90 ExplicitTermsSal.F90\
	  ExplicitTermsVX.F90 ExplicitTermsVY.F90 ExplicitTermsVZ.F90\
	  GlobalQuantities.F90 HdfReadContinua.F90 HdfRoutines.F90\
	  ImplicitAndUpdateTemp.F90 ImplicitAndUpdateSal.F90\
	  ImplicitAndUpdateVX.F90 ImplicitAndUpdateVY.F90 ImplicitAndUpdateVZ.F90\
	  InitPressureSolver.F90 InitTimeMarchScheme.F90 InitVariables.F90\
          LocateLargeDivergence.F90 MpiAuxRoutines.F90 QuitRoutine.F90\
	  ReadInputFile.F90 ResetLogs.F90 SetTempBCs.F90\
          SlabDumpRoutines.F90 SolveImpEqnUpdate_Temp.F90 SolveImpEqnUpdate_Sal.F90\
	  SolveImpEqnUpdate_X.F90 SolveImpEqnUpdate_YZ.F90 SolvePressureCorrection.F90\
          StatReadReduceWrite.F90 StatRoutines.F90\
	  TimeMarcher.F90 WriteFlowField.F90 WriteGridInfo.F90 factorize.F90\
          main.F90\
	  MakeMovieXCut.F90 MakeMovieYCut.F90 MakeMovieZCut.F90\
	  SpecRoutines.F90\
	  CalcPlateCf.F90 CalcWriteQ.F90\
	  CreateMgrdGrid.F90 CreateMgrdStencil.F90 InterpVelMgrd.F90 InterpSalMgrd.F90\
	  CalcMeanProfiles.F90\
	  ReadFlowInterp.F90 CreateOldGrid.F90 CreateInputStencil.F90 CreateSalStencil.F90\
	  InterpInputSal.F90 InterpInputVel.F90 UpdateScalarBCs.F90

#=======================================================================
#  Files that create modules:
#=======================================================================
MFILES = param.F90 decomp_2d.F90 AuxiliaryRoutines.F90 decomp_2d_fft.F90

# Object and module directory:
OBJDIR=obj
OUTDIR=outputdir outputdir/stst3 outputdir/stst outputdir/flowmov outputdir/flowmov3d
OBJS  := $(FFILES:%.F90=$(OBJDIR)/%.o)
MOBJS := $(MFILES:%.F90=$(OBJDIR)/%.o)

# when using ifort compiler:
FC += -module $(OBJDIR) 
# when using gfortran:
# FC += -J $(OBJDIR) 

#============================================================================ 
#  make PROGRAM   
#============================================================================
PROGRAM = afid 

#Compiling 
all: objdir outdir $(PROGRAM) 
$(PROGRAM): $(MOBJS) $(OBJS) 
	$(FC) -o $@ $^ $(LDFLAGS) 

#============================================================================
#  Dependencies 
#============================================================================
$(OBJDIR)/param.o: src/param.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/AuxiliaryRoutines.o: src/AuxiliaryRoutines.F90 
	$(FC) -c -o $@ $< $(LDFLAGS) 
$(OBJDIR)/decomp_2d.o: src/decomp_2d.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/decomp_2d_fft.o: src/decomp_2d_fft.F90
	$(FC) -c -o $@ $< $(LDFLAGS) 
$(OBJDIR)/%.o: src/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)

#============================================================================
#  Clean up 
#============================================================================
clean: 
	/bin/rm -rf $(OBJDIR)/*.o $(OBJDIR)/*.mod $(OBJDIR)/*genmod* $(OBJDIR)/*.o obj\

.PHONY: objdir outdir
objdir: $(OBJDIR) 
$(OBJDIR): 
	mkdir -p ${OBJDIR} 
#outdir: $(OUTDIR) 
# $(OUTDIR): 
# 	mkdir -p ${OUTDIR} 

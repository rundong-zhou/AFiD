# Choose the machine being used
# Options: PC_GNU, PC_INTEL, (i)SNELLIUS, IRENE(_SKL/_ROME), MARENOSTRUM, SUPERMUC
MACHINE=PC
FLAVOUR=GNU
# Modules required for each HPC system as follows:
# SNELLIUS:
#	GNU: 2022 foss/2022a HDF5/1.12.2-gompi-2022a
# 	Intel: 2022 intel/2022a FFTW/3.3.10-GCC-11.3.0 HDF5/1.12.2-iimpi-2021a
# IRENE (Intel): flavor/hdf5/parallel hdf5 fftw3/gnu
# MARENOSTRUM (Intel): fabric intel mkl impi hdf5 fftw szip
# SUPERMUC (Intel): fftw hdf5
# DISCOVERER:
#	GNU: hdf5/1/1.14/latest-gcc-openmpi fftw/3/latest-gcc-openmpi lapack
#	Intel: hdf5/1/1.14/latest-intel-openmpi fftw/3/latest-gcc-openmpi mkl

#=======================================================================
#  Compiler options
#=======================================================================

# Object and module directory:
OBJDIR=obj

ifeq ($(FLAVOUR),GNU)
	FC = h5pfc -cpp -fdefault-real-8 -fdefault-double-8 -fallow-argument-mismatch
else
	FC = h5pfc -fpp -r8
endif

ifeq ($(MACHINE),PC)
# GNU Debug Flags
# FC += -O0 -g -fbacktrace -Wall -Wextra
# FC += -Wpedantic
# FC += -Warray-temporaries
# FC += -fcheck=all -finit-real=snan -ffpe-trap=invalid #-std=f2018
# FC += -pg -fbacktrace -fbounds-check
# Intel Debug Flags
# FC += -O0 -g -traceback -check bounds
	ifeq ($(FLAVOUR),GNU)
		LDFLAGS = -L$(HOME)/fftw-install/lib -lfftw3 -llapack -ldl
	else
		LDFLAGS = -lfftw3 -qmkl=sequential
	endif
endif
ifeq ($(MACHINE),DISCOVERER)
	ifeq ($(FLAVOUR),GNU)
		LDFLAGS += -lfftw3 -llapack -ldl
	else
		LDFLAGS += -lfftw3 -qmkl=sequential
	endif
endif
ifeq ($(MACHINE),SNELLIUS)
	ifeq ($(FLAVOUR),GNU)
		FC += -O2 -march=znver1 -mtune=znver1 -mfma -mavx2 -m3dnow -fomit-frame-pointer
		LDFLAGS = -lfftw3 -lopenblas -ldl
	else
		FC += -align array64byte -fma -ftz -fomit-frame-pointer
		LDFLAGS = -lfftw3 -qmkl=sequential
	endif
endif
ifeq ($(MACHINE),IRENE)
	FC += -mtune=skylake -xCORE-AVX512 -m64 -fPIC $(FFTW3_FFLAGS)
	LDFLAGS = $(FFTW3_LDFLAGS) $(MKL_LDFLAGS) -ldl
endif
ifeq ($(MACHINE),MARENOSTRUM)
	FC += -mtune=skylake -xCORE-AVX512 -m64 -fPIC $(FFTW_FFLAGS)
	LDFLAGS = $(FFTW_LIBS) -mkl=sequential
endif
ifeq ($(MACHINE),SUPERMUC)
	FC = mpif90 -fpp -r8 -O3 $(HDF5_INC)
	LDFLAGS = $(FFTW_LIB) $(HDF5_F90_SHLIB) $(HDF5_SHLIB) -qmkl=sequential
endif

ifeq ($(FLAVOUR),GNU)
	FC += -J $(OBJDIR)
else
	FC += -module $(OBJDIR)
endif

#=======================================================================
#  Non-module Fortran files to be compiled:
#=======================================================================
EXTRA_DIST = transpose_z_to_x.F90 transpose_x_to_z.F90 transpose_x_to_y.F90\
	     transpose_y_to_x.F90 transpose_y_to_z.F90 transpose_z_to_y.F90\
	     factor.F90 halo.F90 fft_common.F90 alloc.F90 halo_common.F90

# Object files associated with standard flow solver
OBJS = obj/main.o obj/CalcLocalDivergence.o obj/CalcMaxCFL.o \
	obj/CalcMeanProfiles.o obj/CheckDivergence.o obj/CorrectPressure.o \
	obj/CorrectVelocity.o obj/CreateGrid.o obj/CreateInitialConditions.o \
	obj/DeallocateVariables.o obj/DebugRoutines.o obj/ExplicitTermsTemp.o \
	obj/ExplicitTermsVX.o obj/ExplicitTermsVY.o obj/ExplicitTermsVZ.o \
	obj/factorize.o obj/HdfReadContinua.o obj/HdfRoutines.o \
	obj/ImplicitAndUpdateTemp.o obj/ImplicitAndUpdateVX.o obj/ImplicitAndUpdateVY.o \
	obj/ImplicitAndUpdateVZ.o obj/InitPressureSolver.o obj/InitTimeMarchScheme.o \
	obj/InitVariables.o obj/LocateLargeDivergence.o obj/MakeMovieXCut.o \
	obj/MakeMovieYCut.o obj/MakeMovieZCut.o obj/MpiAuxRoutines.o \
	obj/QuitRoutine.o obj/ReadInputFile.o obj/ResetLogs.o \
	obj/SetTempBCs.o obj/SolveImpEqnUpdate_Temp.o obj/SolveImpEqnUpdate_X.o \
	obj/SolveImpEqnUpdate_YZ.o obj/SolvePressureCorrection.o obj/SpecRoutines.o \
	obj/TimeMarcher.o obj/WriteFlowField.o obj/WriteGridInfo.o \
	obj/CalcWriteQ.o obj/GlobalQuantities.o obj/ReadFlowInterp.o

# Object files associated with multiple resolution grids
OBJS += obj/CreateMgrdGrid.o obj/InitMgrdVariables.o \
	obj/DeallocateMgrdVariables.o obj/CreateMgrdStencil.o# obj/CreateMgrdStencil.o

# Object files associated with initial condition interpolation
OBJS += obj/CreateNewInputStencil.o obj/CreateOldGrid.o obj/CreateNewSalStencil.o \
	obj/InterpInputSal.o obj/InterpInputVel.o obj/InterpSalMgrd.o \
	obj/InterpVelMgrd.o obj/InitInputVars.o obj/DeallocateInputVars.o \
	obj/InterpInputPhi.o# obj/CreateInputStencil.o obj/CreateSalStencil.o

# Object files associated with the salinity field
OBJS += obj/ExplicitTermsSal.o obj/ImplicitAndUpdateSal.o obj/SolveImpEqnUpdate_Sal.o \
	obj/UpdateScalarBCs.o obj/CreateICSal.o obj/InitSalVariables.o \
	obj/DeallocateSalVariables.o obj/SetSalBCs.o

# Object files associated with the phase-field method
OBJS += obj/AddLatentHeat.o obj/DeallocatePFVariables.o obj/ExplicitTermsPhi.o \
	obj/ImplicitAndUpdatePhi.o obj/InitPFVariables.o obj/InterpPhiMgrd.o \
	obj/InterpTempMgrd.o obj/SolveImpEqnUpdate_Phi.o obj/CreateICPF.o \
	obj/ImmersedBoundary.o obj/UpdateIBMLocation.o

# # Object files associated with the immersed boundary method
OBJS += obj/SolveImpEqnUpdate_Temp_ibm.o obj/SolveImpEqnUpdate_X_ibm.o \
	obj/SolveImpEqnUpdate_YZ_ibm.o obj/topogr_ibm.o obj/SolveImpEqnUpdate_Sal_ibm.o \
	obj/DeallocateIBMVars.o

# Object files for plane writing
OBJS += obj/mean_zplane.o

# Module object files
MOBJS = obj/param.o obj/decomp_2d.o obj/AuxiliaryRoutines.o obj/decomp_2d_fft.o \
	obj/HermiteInterpolations.o obj/GridModule.o obj/h5_tools.o obj/means.o \
	obj/ibm_param.o obj/IBMTools.o

#=======================================================================
#  Files that create modules:
#=======================================================================
MFILES = param.F90 decomp_2d.F90 AuxiliaryRoutines.F90 decomp_2d_fft.F90 \
	HermiteInterpolations.F90 GridModule.F90 ibm_param.F90 IBMTools.F90

#============================================================================ 
#  make PROGRAM   
#============================================================================
PROGRAM = afid 

#Compiling 
all: objdir $(PROGRAM) 
$(PROGRAM): $(MOBJS) $(OBJS) 
	$(FC) -o $@ $^ $(LDFLAGS) 

#============================================================================
#  Dependencies 
#============================================================================
$(OBJDIR)/param.o: src/flow_solver/param.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/AuxiliaryRoutines.o: src/flow_solver/AuxiliaryRoutines.F90 
	$(FC) -c -o $@ $< $(LDFLAGS) 
$(OBJDIR)/decomp_2d.o: src/flow_solver/2decomp/decomp_2d.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/decomp_2d_fft.o: src/flow_solver/2decomp/decomp_2d_fft.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/ibm_param.o: src/ibm/ibm_param.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/GridModule.o: src/flow_solver/GridModule.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/HermiteInterpolations.o: src/multires/HermiteInterpolations.F90 obj/ibm_param.o
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/h5_tools.o: src/h5tools/h5_tools.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/means.o: src/h5tools/means.F90 obj/ibm_param.o
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/IBMTools.o: src/ibm/IBMTools.F90
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/flow_solver/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/h5tools/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/multires/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/multires/IC_interpolation/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/multires/phase-field/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/multires/salinity/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)
$(OBJDIR)/%.o: src/ibm/%.F90 $(MOBJS)
	$(FC) -c -o $@ $< $(LDFLAGS)

#============================================================================
#  Clean up 
#============================================================================
clean: 
	/bin/rm -rf $(OBJDIR)/*.o $(OBJDIR)/*.mod $(OBJDIR)/*genmod* $(OBJDIR)/*.o obj\

.PHONY: objdir
objdir: $(OBJDIR) 
$(OBJDIR): 
	mkdir -p ${OBJDIR}

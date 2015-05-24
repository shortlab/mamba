# Start of the makefile

FC = f95
OBJ = dlsode.o chexal.o radical.o
SRC = src

# flags for debugging or for maximum performance, comment as necessary

FCFLAGS = -g -fbounds-check -fdefault-integer-4
FCFLAGS = -O2

# flags for all (e.g. look for system .mod files, required in gfortran)

FCFLAGS += -I/usr/include
FCFLAGS += -Iinclude

# libraries needed for linking, unused in the examples
#LDFLAGS = -li_need_this_lib

# List of executables to be built within the package
PROGRAMS = radical

# "make" builds all
all: $(PROGRAMS)

# Link command
radical: $(OBJ)
	$(FC) $(FCFLAGS) $(OBJ) -o radical

# Compilation commands
%.o: $(SRC)/%.for
	$(FC) $(FCFLAGS) -c $(input) $<

# Cleaning everything
clean:
	rm -f $(OBJ)
	rm -f radical

# End of the makefile



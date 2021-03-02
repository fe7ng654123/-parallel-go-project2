INC = -I/usr/local/include -I/usr/local/cuda/include/ -I/usr/share/CUnit/include/
LIB = -L/usr/local/lib -L/usr/local/cuda/lib64/
NVCC = /usr/local/cuda/bin/nvcc
LIBS = -lcudart -lcublas /usr/share/CUnit/lib/libcunit.a

all: runtest.c util.c asgn2b.o
	gcc runtest.c util.c asgn2b.o $(INC) $(LIB) $(LIBS) -o runtest -std=c99 -O3
asgn2b.o: asgn2b.cu
	$(NVCC) -o asgn2b.o -c asgn2b.cu $(INC) -O3 

clean:
	rm -rf runtest 
	rm -rf asgn2b.o



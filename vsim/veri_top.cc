#include "Vminion_soc.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

double main_time;

double sc_time_stamp() { return main_time; }

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    int i, clk;
    // init top verilog instance
    Vminion_soc* top = new Vminion_soc;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("mem.vcd");
    // initialize simulation inputs
    top->rstn = 0;
    top->pxl_clk = 1;
    top->clk_200MHz = 1;
    top->msoc_clk = 1;

    i = 0;

    for (clk=0; clk<2; clk++) {
        tfp->dump (2*i+clk);
        top->pxl_clk = !top->pxl_clk;
        top->clk_200MHz = !top->clk_200MHz;
        top->msoc_clk = !top->msoc_clk;
        top->eval ();
    }
    i++;

    top->rstn = 1;

    for(i = 1; i <100; i++) {
        for (clk=0; clk<2; clk++) {
            tfp->dump (2*i+clk);
            top->pxl_clk = !top->pxl_clk;
            top->clk_200MHz = !top->clk_200MHz;
            top->msoc_clk = !top->msoc_clk;
            top->eval ();
        }
    }
    delete top;

    tfp->close();
    exit(0);
}

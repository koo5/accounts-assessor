Numbers are best represented as rationals. These don't suffer from machine-specific maximums and minimums, and don't lose any precision, so, results are deterministic and free of error. But in practice, current Robust system would do just fine with floats too.
Ideally, we'd have "Interval Constraint Logic Programming". This is because our input numbers are naturally intervals. For example, it's 5.58768 precise to 5 decimal (after decimal point) digits. This means anything from 5.587675 to 5.587684

interval arithmetic:
https://github.com/mlliarm/ia

see also ops2.pl

 

a checklist for a clp system:
	* are there limits to how big numbers are representable? if yes, can we at least trap an overflow error, to indicate a failure to user? Or will the processing fail silently, and look like an unsatisfiable model? Or do we simply risk that users will run into "strange fails".
	* rationals or hardware floats? Floats degenerate with a number of operations, and yield different results on different machines. 
	


for (mostly failed) attempts at interval artihmetic with swipl clp see:
* misc/equation_solving/ops/




* https://github.com/ridgeworks/clpBNR_pl
^ but:
```This package sets the SWI-Prolog arithmetic flags as follows:

set_prolog_flag(prefer_rationals, true),           % enable rational arithmetic
set_prolog_flag(max_rational_size, 16),            % rational size in bytes before ..
set_prolog_flag(max_rational_size_action, float),  % conversion to float

set_prolog_flag(float_overflow,infinity),          % enable IEEE continuation values
set_prolog_flag(float_zero_div,infinity),
set_prolog_flag(float_undefined,nan),

This package will not work as intended if these flag values are not respected.```




* https://www.researchgate.net/publication/220622978_Interval_Constraint_Logic_Programming
* dmiles "multi-dimentional constraints patch"?







## SICSTUS
bundled clpfd is constrained to "[-2^60,2^60-1] on 64-bit platforms". This means we wouldn't be able to emulate rationals.
^ err not anymore?
how far along is https://github.com/triska/clpz ?
https://sicstus.sics.se/sicstus/docs/latest4/html/sicstus.html/FDBG-Introduction.html


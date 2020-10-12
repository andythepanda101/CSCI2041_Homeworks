# Homework 4:  Modular Similarity
*CSci 2041: Advanced Programming Principles, Fall 2020 (Section 10)*

**Due:** Monday, November 9 at 11:59pm

**Reminder:** In this class homeworks are a summative activity.  Therefore, unlike lab exercises and reading quizzes, you should only submit code that is the result of your own work and should not discuss solutions to this homework with anyone but the course staff.

However, you *may* ask clarifying questions about these instructions on `#hw-questions` in the course [Slack workspace](https://csci2041-010-f20.slack.com/).  **No code should be posted in this channel.**

## Overview: Modular Document Similarity

In homework 3, we wrote an application  based on the idea of
*document similarity*, which is a first step in many "big data"
applications such as improving search, language recognition, automated document
classification, automated document summary, authorship attribution,
and plagiarism detection.  In this task, we are given a (text) document `d`
to classify along with a list of "representative" documents
`[r_1; r_2; ...; r_N]`, and must choose the document `r_i` that is most
"similar" to `d`.  Our program was tied to one way of summarizing documents: as *multisets* of *3-grams*. (And we represented multisets as associative lists mapping each element to its multiplicity.)

In this assignment, we will use modules and functors to allowing swapping in other summaries of documents. These summaries might have faster implementations or allow better similarity measurement in some contexts.   The beginnings of this application, as well as the same examples we used to test the homework 3 version, are stored in the public `hw2041-f20` repository under
the `hw4` directory.  You should copy this directory to your personal repository
and work there.  A note about testing your code, which will go in the file `similar.ml`, for this problem: some of the code will references functions provided in the file `stemmer.ml`.  So before you start testing functions in `utop`, you'll need to issue the following directives:

```
utop # #mod_use "stemmer.ml";;
```

(`#mod_use "file.ml"` is like `#use "file.ml"` except that the functions and values declared in `file` can be accessed as a module, e.g. as `File.func`)

Follow along as we build our application:

### The "Element" and "Summary" signatures

These are already completed: an `Element` will be a way of representing some of the contents of a document (we will implement an `Ngram` module that allows different sizes of n-gram, and `similar.ml` already implements a `Stem` module which turns a word into its ["stem"](https://en.wikipedia.org/wiki/Word_stem)).  Any module implementing the `Element` interface should have a type `e` of elements (like `string` in both of our examples) and a function `of_string` that turns a document into a `e list`, like a list of n-grams or word stems.

A `Summary` will be a way of representing a document as a collection of `Element.e` values.  We'll port in our implementation of the associative list multiset, and also write two more implementations using the `Set.Make` and `Map.Make` functors in the OCaml standard library.  A module that implements `Summary` should provide a collection type `t`, a function `of_list` that converts a list of elements (an `e list`) into a collection, an empty collection, a function that tells us the size of a collection, and functions that tell us the size of the union and intersection of two collections.

### Task 1: The FindSim functor

The `FindSim` functor uses an `Element` struct and a `Summary` struct to perform the computation we implemented in Homework 3, but using the functions provided by the `E` and `MS` modules given as arguments to the functor rather than directly calling the implementations developed last time.  You will also need to add a sharing constraint to avoid a type error once the implementation is filled in.

(One other difference here is that FindSim.main will return a list of document files in decreasing order of similarity to the target.  This is accomplished by the last line.)

Once this is correctly implemented, we should find that:

+ `ocamlc -w-3 -c str.cma stemmer.ml similar.ml` compiles without warnings and
+ `let module M = FindSim(Nilement)(Nummary) in M.main "nrlist" "narget.txt"` does not cause a type error and evaluates to `[(0.875, "nr/8.txt"); (0.714285714285714302, "nr/5.txt"); (0.142857142857142849, "nr/1.txt")]`

### Task 2 : The Ngram and ListMSet modules

The `Ngram` functor takes a `struct` that specifies the length of n-grams to use, and `of_string` should then compute the same thing as `n_grams` in Homework 3.  So:

+ `let module N = Ngram(struct let n = 3 end) in N.of_string "abc defg"` should evaluate to `["abc";"def";"efg"]`
+ `let module N = Ngram(struct let n = 2 end) in N.of_string "abc defg"` should evaluate to `["ab";"bc";"de";"ef";"fg"]`

The `ListMSet` module should implement the associative list multiset function from HW3: `of_list` should compute `multiset_of_list`, `union_size m1 m2` should compute the size of the union, `inter_size` the size of the intersection, and `size` the sum of the multiplicities in a multiset.  Once you have included these implementations we should have:

+ `ListMSet.of_list ["ab";"ab";"ab";"bc"]` should evaluate to `[("ab",3);("bc",1)]`.
+ `ListMSet.size [("ab",4);("bc",2)]` should evaluate to `6`
+ `ListMSet.union_size [("ab",4);("bc",2)] [("ab",3);("cd",1)]` should evaluate to `7`.
+ `ListMSet.inter_size [("ab",4);("bc",2)] [("ab",3);("cd",1)]` should evaluate to `3`.

### Task 3: The SetSummary module

The `Set.Make` functor accepts a struct that specifies a type `t` and a comparison function `compare : t -> t -> int` and creates a module that implements sets with elements of type `t`.  The OCaml manual specifies the [interface of this module](https://ocaml.org/releases/4.08/htmlman/libref/Set.S.html) in sufficient detail that if you pay careful attention to the documentation you should be able to implement `size`, `union_size`, and `inter_size` as one-liners, and `of_list` as a simple fold of the argument list.

If correctly implemented, the following tests should compile and have the expected results:

+ `let s : Set.Make(String).t = SetSummary.empty in true` should evaluate to `true`
+ `let s : Set.Make(String).t = SetSummary.empty in s = SetSummary.of_list ["a"]` should evaluate to `false`
+ `SetSummary.size (SetSummary.of_list ["a";"b"])` should evaluate to 2
+ `SetSummary.inter_size (SetSummary.of_list ["a";"b"]) (SetSummary.of_list ["a";"c"])` should evaluate to `1`
+ `SetSummary.union_size (SetSummary.of_list ["a";"b"]) (SetSummary.of_list ["a";"c"])` should evaluate to `3`

### Task 4: The MapMSet module

The `Map.Make` functor accepts a struct that specifies a key type `key` and a comparison function `compare : key -> key -> int` and creates a module that implements efficient dictionaries of type `'a t`, so for example an `int Map.Make(String).t` is a dictionary that maps `string` keys to `int` values.   Carefully reading the [interface documentation](https://ocaml.org/releases/4.08/htmlman/libref/Set.S.html) for this functor should allow you to fill in a more efficient implementation of multisets using `int Map.Make(String).t` rather than associative lists.  That is, if correctly implemented, the `MapMSet` module's functions should have the same results as `ListMSet` but should be compute the intersection and unions more efficiently.  Fill in this implementation so that:

+ `let ms : int Map.Make(String).t = MapMSet.empty in ms = MapMSet.of_list []` compiles without a type error and evaluates to `true`
+ `MapMSet.size (MapMSet.of_list ["ab";"ab";"ab";"bc"])` should evaluate to 4.
+ `MapMSet.union_size (MapMSet.of_list ["ab";"ab";"bc"]) (MapMSet.of_list ["ab";"cd"])` should evaluate to `4`.
+ `MapMSet.inter_size (MapMSet.of_list ["ab";"ab";"bc"]) (MapMSet.of_list ["ab";"cd"])` should evaluate to `1`.

### Task 5: The `modsim.ml` file

Now that we have implementations of `Ngram` and `Stem` for `Element` and `ListMSet`, `SetSummary`, and `MapMSet` for `Summary`, let's finish the `modsim.ml` file, which, similar to the `findsim.ml` file in HW3, gets a target file and comparison list file from the command line and calls the main function.  Here, though, we need to first apply the `FindSim` functor to the correct arguments to create an appropriate `main` function to call.  (The skeleton does this for the command line arguments that specify our original parameters, `ListMSet` and 3-grams, as well as `SetSummary` and n-grams)  Fill in the remaining 4 options for `"--map"` and `"--stem"` in `do_main`.  Also, it is possible that a user might specify an unknown command-line option or give a string that cannot be converted to an integer where such is required (e.g. the size of n-gram to use or the number of results to print).  Alter the final call to `setargs` so that failures of this kind can be handled with an output that lists the options the program understands.

### Testing it out

Testing it out: compiling the entire application requires a specific sequence of
arguments to `ocamlc`, because the OCaml compiler does not resolve
"dependencies" automatically - it can't figure out which source files reference other
source files or libraries, requiring those to be built or linked first.  So we'll need
to list them in the right order.  Here's what we know:

+ The source file `modsim.ml` is the command-line driver that calls `main` in
`similar.ml` with the command-line arguments.  So it needs to be compiled after
`similar.ml`

+ `similar.ml` calls functions in `stemmer.ml`, so it needs
to be compiled after that file;

+ `similar.ml` and `stemmer.ml` both use the `Str` library, so the first argument should be `str.cma`. (or `str.cmxa` for `ocamlopt`)

Putting these all together, we can compile our application with the command:

```
% ocamlopt -o modsim str.cmxa stemmer.ml similar.ml modsim.ml
```

Once we've built the executable file, we can test it out.  The directory
`authors` contains a set of 9 text files taken from Project Gutenberg, and the directory `targets` contains text files with the beginnings of 9 other novels by the same authors.  The file `authorlist` simply lists the 10 labelled author files. If we run `modsim` with this representative list against
various target files, we should see something like the following output:

```
(repo-user1234/hw4/ ) % ./modsim --mset --ngram 3 --top 4 authorlist targets/alices-adventures-in-wonderland.txt
0.7040	./authors/carroll.txt
0.5549	./authors/christie.txt
0.5548	./authors/dubois.txt
0.5521	./authors/conrad.txt
(repo-user1234/hw4/ ) % ./modsim --set --ngram 2 authorlist targets/heart-of-darkness.txt
0.9161	./authors/doyle.txt
0.8894	./authors/dickens.txt
0.8879	./authors/conrad.txt
(repo-user1234/hw4/ ) % ./modsim --map --stem --top 4 authorlist targets/tale-of-two-cities.txt
0.7109	./authors/dickens.txt
0.6935	./authors/conrad.txt
0.6533	./authors/stoker.txt
0.6426	./authors/shelley.txt
(repo-user1234/hw4/ ) % ./modsim --funny-arg authorlist targets/tale-of-two-cities             

modsim: modular similarity comparison tool. options:
--ngram n : use <n>-grams
--stem : use word stems
--set : use set similarity
--mset : use multiset similarity (list implementation)
--map : use multiset similarity (map implementation)
--top k : print top <k> matches only
```
(Note: you should always see the same output for `--map` and `--mset`; the difference is that we expect `--map` to be more efficient due to the use of a balanced tree structure rather than a list to compute unions and intersections.)

## All done!

In addition to satisfying the functional specifications given above, your code should be readable, with comments that explain what you're trying to accomplish.  It must compile with the command line given above.  Finally, solutions that pay careful attention to resources like running time and stack space (e.g. using tail recursive options wherever feasible or prefering linear or n lg n-time algorithms to quadratic-time algorithms) and code reuse are worth more than solutions that do not have these properties.  

## Submission instructions and late grading requests

Once you are satisfied with the status of your submission in github, you can upload the files `similar.ml` and `modsim.ml` to the "Homework 4" assignment on [Gradescope](https://www.gradescope.com/courses/159067).  We will run additional correctness testing to the basic feedback tests described here, and provide some manual feedback on the efficiency, readability, structure and comments of your code, which will be accessible in Gradescope once all homeworks have been graded.  ***Note:*** Your homework will *only* be considered submitted once you have submitted it to Gradescope; having your work only on github will not be sufficient.

**Late Grading**: Keep in mind that each student is allowed one "late grading request" this semester.  If you choose to use this request for this homework, then you should submit a file named `late_request.txt` by the submission deadline.  You will then have until 11:59pm (CST) on Thursday, November 12th to submit to the "Homework 4 Late" assignment.

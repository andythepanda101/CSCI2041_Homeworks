# Homework 3:  Mapping, Folding and Filtering away recursion
*CSci 2041: Advanced Programming Principles, Fall 2020 (Section 10)*

**Due:** Monday, October 26 at 11:59pm

**Reminder:** In this class homeworks are a summative activity.  Therefore, unlike lab exercises and reading quizzes, you should only submit code that is the result of your own work and should not discuss solutions to this homework with anyone but the course staff.

However, you *may* ask clarifying questions about these instructions on `#hw-questions` in the course [Slack workspace](https://csci2041-010-f20.slack.com/).  **No code should be posted in this channel.**

## Overview: Document Similarity without recursion

In this problem, we will write an entire command-line application that
computes an iterative task without any explicit recursion or looping.

The problem our application will solve is based on the idea of
*document similarity*, which is a first step in many "big data"
applications such as improving search, language recognition, automated document
classification, automated document summary, authorship attribution,
and plagiarism detection.  In this task, we are given a (text) document `d`
to classify along with a list of "representative" documents
`[r_1; r_2; ...; r_N]`, and must choose the document `r_i` that is most
"similar" to `d`.   Your program will be run from the command line
with two arguments - the name of a file listing the files holding the
representative documents, and the name of a target file.  Eventually,
your program will compare this target file to each file listed in the
first file, decide which is the most similar, and print out a message
reporting the most similar document and how close it is to the target
document.

The beginnings of this application, as well as some examples you can
use to test it, are stored in the public `hw2041-f20` repository under
the `hw3` directory.  You should copy this directory to your personal repository
and work there.  A note about testing your code, which will go in the file `similar.ml`, for this problem: some of your code will need to reference functions provided in the file `fTools.ml`.  So before you start testing functions in `utop`, you'll need to issue the following directives:

```
utop # #mod_use "fTools.ml";;
```

(`#mod_use "file.ml"` is like `#use "file.ml"` except that the functions and values declared in `file` can be accessed as a module, e.g. as `File.func`)

Follow along as we build our application:

### Reading the file list

Your program should read the list of names of representative files from a file
whose name is passed in as the first command line argument.  For
instance, if we call your program from the command line as
`findsim list.txt example.txt` then the file `list.txt`
should contain a list of representative text files, one on each line.
The file `fTools.ml` contains definitions for the two I/O functions
you'll need for this assignment; `file_lines : string -> string list`
takes as input a file name and returns a list of lines in the file.

**Task 1:** Modify the first line of `main` -- `let repfile_list = [""]` -- to bind `repfile_list` to the list of file names stored in the file named by the argument `replist_name`.


### Reading the representative files, and the document

The other I/O function defined in `fTools.ml` is `file_as_string :
string -> string`: given a file name, it returns the entire
contents of the file as a string.  

**Task 2:** Still working in the `main` function at the bottom of `similar.ml`, modify the next two lines so that using `file_as_string` and an appropriate list function, `target_contents` is bound to the contents of the target file (passed as a name in `target_name`), and `rep_contents` is bound to a list of strings, containing the string contents of each representative file.

### Task 3: Splitting into n-grams

Our distance mechanism treats text documents as *multisets* of *n-grams*.  We'll describe  multisets below.  *n-grams* are sequences of n consecutive letters from a string, so for example, in the string "Bazinga", the 3-grams are "Baz", "azi", "zin", "ing", and "nga".  (We'll use n=3, which we've declared at the top of `similar.ml`, for this assignment) We'll build a function to extract "normalized" n-grams from a string in three steps:

1. First, fill in the definition for the "naive" n-gram function `ngrams : int -> string -> string list`.  The `List.init` function (which takes as input an integer `n` and a function `f : int -> 'a` and produces the list `[(f 0); (f 1); ... (f (n-1)]`) and `String.sub` will be useful here. Some example evaluations: `ngrams 2 "hallo!"` should evaluate to `["ha"; "al"; "ll"; "lo"; "o!"]` and `ngrams 3 "shirtballs"` should evaluate to `["shi"; "hir"; "irt"; "rtb"; "tba"; "bal"; "all"; "lls"]`.

2.  Second, punctuation, capitalization, stray digits and other non-alphabetic characters are not as important for the similarity of documents, so we should remove them from our strings. We can handle this by "preprocessing" the string using `String.lowercase_ascii` and `String.map` to turn any non-alphabetic character into a space, `' '`.  Fill in the function `cleanup_chars` to accomplish this goal.  Some example evaluations: `cleanup_chars "abc123"` should evaluate to `"abc   "` and `cleanup_chars "SAD!!!!!!!"` should evaluate to `"sad       "`.

3. Finally, the `string list` returned by `ngrams` will include some strings that
   are only or primarily made up of space characters.  We can remove these from the
   result of `ngrams` using a `List` higher-order function; `String.contains s c` will tell us if string `s` contains character `c`.  

Define a function, `n_grams : string -> string list` that combines the
preprocessing in step 2 with a call to `ngrams ngram_n` and the
postprocessing (removing whitespace strings) in step 3 into a single
function. Some examples: `n_grams "I continued to use almond milk in my coffee"` should
evaluate to `["con"; "ont"; "nti"; "tin"; "inu"; "nue"; "ued"; "alm"; "lmo"; "mon"; "ond";
 "mil"; "ilk"; "cof"; "off"; "ffe"; "fee"]` and `n_grams "DRESS BENCH!"` should evaluate to `["dre"; "res"; "ess"; "ben"; "enc"; "nch"]`.  Remember, use `let`
and `List` and `String` functions only, no explicit recursion!

Once you've got `n_grams` working, modify the next two let bindings in main so that:

+ `rep_ngrams` is bound to a list of lists of n-grams, one list for each representative text file
+ `target_ngrams` is bound to a list of the n-grams in the target text file

### Task 4: Converting to multisets

We'll represent each document as a *multiset of n-grams*.  A *multiset* is an unordered mathematical object like a set, except that all elements have a non-negative *multiplicity* associated with them: an element that is not in the multiset has multiplicity 0, an element that appears once has multiplicity 1, and so on.  We'll represent a multiset as an associative list pairing each n-gram in the multiset with its multiplicity.  Add a definition  (using `let`, not `let rec`) for the function `multiset_of_list : 'a list -> ('a*int) list` using an appropriate `List` higher-order function (you may find it useful to separately define the argument to your higher-order function, and to sort the list before processing it.) Some examples: `multiset_of_list ["a"; "b"; "a"; "b"]` should evaluate to (a permutation of) `[("b",2); ("a",2)]` and `multiset_of_list ["a"; "a"; "b"; "c"; "b"; "a"]` should evaluate to (a permutation of) `[("c",1); ("b",2); ("a", 3)]`.

Modify the next two let bindings to convert the list of lists of n-grams (`rep_ngrams`) into a list of multisets of n-grams (`rep_multisets`) from the representative documents, and convert the list of n-grams from the target document (`target_ngrams`) into a multiset of n-grams (`target_multiset`).

### Task 5: Define the similarity function

We define the similarity between two documents to be the ratio of the size of the intersection of their n-gram multisets to the size of the union of their n-gram multisets.  The intersection of two multisets is the multiset in which each element has multiplicity the minimum of its multiplicities in the two multisets, and the union is the multiset in which each element has multiplicity the maximum of its multiplicities in the two multisets. The size of a multiset is the sum of the multiplicities of all of the elements in the multiset.  Add function definitions that use `List` functions to compute `intersection_size : ('a * int) list -> ('a * int) list -> int`, the intersection size of two multisets represented by associative lists (you may find it useful to define a helper function `multiplicity : ('a * int) list -> int`);
`union_size : ('a * int) list -> ('a * int) list -> int`, the size of the union of two multisets represented by associative lists; and `similarity : ('a * int) list -> ('a * int) list -> float`.  (Don't forget to convert to floats before the division!)
Some examples: `intersection_size [("a",2); ("b",1)] [("a",1); ("c",1)]` should evaluate to
`1`, `union_size [("a",2); ("b",1)] [("a",1); ("c",1)]` should evaluate to `4` and
`similarity [("a",2); ("b",1)] [("a",1); ("c",1)]` should evaluate to `0.25`.

Modify the next let binding to compute `repsims`, the list of similarities between each representative document and the target file.

### Task 6: Compute the closest document

Now that we have ngram sets for all of the representative files and the target
file, and the similarities of each representative file to the target file, we
can compute which representative file is most simliar to the target text file,
and its similarity to the target file.  Fill in the definition of the function
`find_max : float list -> string list -> float*string` which finds the name and
similarity of the file closest to the target document.  If two or more representative
files have the same similarity, your function should return the file name that is
lexicographically greatest, and if the input lists are empty, it should return `(0.,"")`.
A few hints:

+ The list function `List.combine` is the same as the `zip` function
we have seen in class before

+ The built-in function `max` on tuples orders its arguments by the first element of the tuples, then the second, and so on.

An example evaluation: `find_max [0.;0.2;0.1] ["a";"b";"c"]` should evaluate to `(0.2,"b")`.  Once you've defined `find_max`, modify the next `let` binding in `main`
so that `best_rep` is the name of the most similar representative file and `sim` is its
similarity to the target file.

### Task 7: Print out the result(s)

Finally, now that you have the result, modify `main` so that:

- if the "all" parameter is true, we print out a header line in the format `"File\tSimilarity"`, and then the similarity and file name of each representative
file to the target file are printed, in the order they appear in the repfile_list,
one per line, in the format `"<repfile name>\t<score>"`.  You may find the function `List.iter2` helpful for this case.

- Otherwise, print out two lines telling us the best result.  On the first line,
you should print `"The most similar file to <target file name> was <representative file name>"`, and on the second line, print `"Similarity: <score>"`.

Testing it out: compiling the entire application requires a specific sequence of
arguments to `ocamlc`, because the OCaml compiler does not resolve
"dependencies" automatically - it can't figure out which source files reference other
source files or libraries, requiring those to be built or linked first.  So we'll need
to list them in the right order.  Here's what we know:

+ The source file `findsim.ml` is the command-line driver that calls `main` in
`similar.ml` with the command-line arguments.  So it needs to be compiled after
`similar.ml`

+ `similar.ml` should call functions in `fTools.ml`, so it needs
to be compiled after that file;

+ `fTools.ml` does not call any other module.  So the first thing we need to tell `ocamlc` to include is `fTools.ml`.

Putting these all together, we can compile our application with the command:

```
% ocamlopt -o findsim fTools.ml similar.ml findsim.ml
```

Once we've built the executable file, we can test it out.  The directory
`authors` contains a set of 9 text files taken from Project Gutenberg, and the directory `targets` contains text files with the beginnings of 9 other novels by the same authors.  The file `authorlist` simply lists the 10 labelled author files. If we run `findsim` with this representative list against
various target files, we should see something like the following output:

```
(repo-user1234/hw3/ ) % ./findsim --all authorlist targets/alices-adventures-in-wonderland.txt
File	Similarity
./authors/austen.txt	0.487439367344
./authors/carroll.txt	0.703978422117
./authors/christie.txt	0.554851435286
./authors/conrad.txt	0.552090673001
./authors/dickens.txt	0.530490354178
./authors/doyle.txt	0.515165980468
./authors/dubois.txt	0.554815164128
./authors/shelley.txt	0.463962146499
./authors/stoker.txt	0.537936001646
(repo-user1234/hw3/ ) % ./findsim --all authorlist targets/heart-of-darkness.txt
File	Similarity
./authors/austen.txt	0.574202237103
./authors/carroll.txt	0.550861963565
./authors/christie.txt	0.609387027509
./authors/conrad.txt	0.724853556485
./authors/dickens.txt	0.662474727052
./authors/doyle.txt	0.634437271962
./authors/dubois.txt	0.624817372161
./authors/shelley.txt	0.604260448647
./authors/stoker.txt	0.641631649072
(repo-user1234/hw3/ ) % ./findsim authorlist targets/dracula.txt
The most similar file to targets/dracula.txt was ./authors/stoker.txt
Similarity: 0.657487017962
```
(Note: implementing intersection_size and union_size using only List higher order functions is somewhat inefficient, and due to the large size of these files, running these comparisons may take 5-15 seconds to complete, depending on the algorithm and hardware you're using.  If you have adequately tested the individual similarity functions you shouldn't need to try this more than a few times.)

Another note to keep in mind: the precise floating point format of your results is not important; the printing portion of the homework will be manually graded.

## All done!

In addition to satisfying the functional specifications given above, your code should be readable, with comments that explain what you're trying to accomplish.  It must compile with the command line given above.  It must not use any recursive `let`s in the `similar.ml` file.  Finally, solutions that pay careful attention to resources like running time and stack space (e.g. using tail recursion wherever feasible) and code reuse are worth more than solutions that do not have these properties.  

## Submission instructions and late grading requests

Once you are satisfied with the status of your submission in github, you can upload the file `similar.ml` to the "Homework 3" assignment on [Gradescope](https://www.gradescope.com/courses/159067).  We will run additional correctness testing to the basic feedback tests described here, and provide some manual feedback on the efficiency, readability, structure and comments of your code, which will be accessible in Gradescope once all homeworks have been graded.  ***Note:*** Your homework will *only* be considered submitted once you have submitted it to Gradescope; having your work only on github will not be sufficient.

**Late Grading**: Keep in mind that each student is allowed one "late grading request" this semester.  If you choose to use this request for this homework, then you should submit a file named `late_request.txt` by the submission deadline.  You will then have until 11:59pm (CST) on Thursday, October 29th to submit to the "Homework 3 Late" assignment.

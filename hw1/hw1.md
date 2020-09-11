# Homework 1: Table Selection

*CSci 2041: Advanced Programming Principles, Fall 2020 (Section 10)*

**Due:**  Monday, September 28 at 11:59pm

In the `hw2041-f20/hw1` directory, you will find files named `tables.ml` and `select.ml`.
Create a directory named `hw1` in your personal repository, and copy both of these files
to your `hw1` directory.  Don't forget to run `git add` on both the directory and
the files!

**Reminder:** In this class homeworks are a summative activity.  Therefore, unlike lab exercises and reading quizzes, you should only submit code that is the result of your own work and should not discuss solutions to this homework with anyone but the course staff.

However, you *may* ask clarifying questions about these instructions on `#hw-questions` in the course [Slack workspace](https://csci2041-010-f20.slack.com/).  **No code should be posted in this channel.**

## Background: Command Line programs

Every homework in this class will involve eventually creating a
program that can be run from the "command line" in a terminal.  We will
typically include directions for building these programs in the homework.  They
can usually be compiled with `ocamlc` or `ocamlopt` but sometimes (later in the
semester) we'll use additional libraries and it will be easier to use
`ocamlbuild` to resolve the dependencies between files.  

Command line programs typically take arguments on the command line, for example,
like `git` or `ssh`.  They also often need to read or write outputs to files, or
in the case of many Unix/linux utilities, can read an input file from the "standard
input" and write to the "standard output."  As you probably know, a command line
program's standard input can be "redirected" to use a file with the `<`
operator, and its standard output can be redirected with the `>` operator.  (So
for example, if you type `git status >git.out` in the terminal while your
working directory is within a git repo, the result will go to a file named
`git.out` that you can read with your favorite text editor, or `less`)

## Background: Tables

A very common way of storing data for presentation or manipulation is as a table.  While spreadsheet applications like Excel, Numbers, Google Sheets, and LibreOffice each have their own customized format for storing tables, it is also common to store tables as lines of a text file, with a "delimiter" character between the columns in each row.  So the table:

Last Name | First Name | Birth Year | Email | House
--- | --- | --- | --- | ---
Potter  | Harry | 1980  | pott213@hogwarts.ac.uk | Gryffindor
Granger | Hermione | 1979 | gran371@hogwarts.ac.uk | Gryffindor
Malfoy | Draco | 1980 | malf091@hogwarts.ac.uk | Slytherin
Chang | Cho | 1979 | chan010@hogwarts.ac.uk | Ravenclaw
Diggory | Cedric | 1977 | digg131@hogwarts.ac.uk | Hufflepuff

Might be stored in a file named `students.csv` with contents:

```
Last Name, First Name, Birth Year, Email, House
Potter, Harry, 1980, pott213@hogwarts.ac.uk, Gryffindor
Granger, Hermione, 1979, gran371@hogwarts.ac.uk, Gryffindor
Malfoy, Draco, 1980, malf091@hogwarts.ac.uk, Slytherin
Chang, Cho, 1979, chan010@hogwarts.ac.uk, Ravenclaw
Diggory, Cedric, 1977, digg131@hogwarts.ac.uk, Hufflepuff
```

Here the delimiter is `,`; if you are reading this file in a text editor, you'll
notice that markdown also stores tables as a collection of lines, with columns
delimited by `|`.  Another common delimiter for storing tables in text files is
the tab character, `\t`.

This table has six *rows*, including the headings, and five *columns*.  Often it is useful to be able to *rearrange* or *delete* some of the columns.  It can also be useful to convert a table using one delimiter into a table using a different delimiter. For Homework 1, we'll write a tool that supports these operations.

## Homework 1: `select`

In this homework your goal will be to write a command line tool called `select` that will read a table from the standard input and write a table to the standard output.  `select` will support the following transformations:

+ "select" a sublist of the input columns to be included in the output.  These columns can be specified either as indices (1,2,3...) or by names, if the input table has a "header" row.

+ sort the input rows in increasing or decreasing order, by a given column identifier (an index or column header).

+ change between column delimiters.

+ keep only the first k rows of the table (not counting the header row)

So for example, we might run the command `select -hr -c "Last Name,First Name" -s House -k 4 -od $'\t'` with input from the above `students.csv` file to get an output like:
    ```
    Last Name   First Name
    Potter      Harry
    Granger     Hermione
    Diggory     Cedric
    Chang       Cho
    ```
The `select` command will also print out a summary of the command line options it supports if run with an input it does not understand.

To get started, open `tables.ml` in your favorite text editor, and you'll see that there's some
implementation in the file already:

+ `read_lines : unit -> string list` reads from standard input and returns a
list of strings, one for each line in the input.

+ `make_row : string -> string -> string list` takes a delimiter and a line, and
returns a list of strings separated by the delimiter.  It trims extra whitespace
from these strings as well.

+ `write_row : string list -> string -> unit` takes a list of strings `r` and a
delimiter `delim`, and writes each string in `r` to the standard output, with
the string `delim` as the delimiter.

+ `output_table : string -> string list list -> unit` takes a delimiter and a
list of lists of strings, and prints each string list as a separate line
(delimited by the first input) on the standard output.

There's one more function fully implemented in `tables.ml`, which is `main`.  This function handles the flow of work to be done by our tool:

+ Read the input from stdin, storing it as a list of strings.

+ Then convert the list of strings into "table format," a list of lists of strings.  The function `table_of_stringlist`, which you'll fill in, does this.

+ Next, convert from this table format to a more convenient representation for the job we want to do, *row-associative format*.  When we're manipulating a table, we'll store it as a `(string*string) list list`: a list of lists of pairs, where if the tuple `(c,e)` is in the `r`-th list, this means that the string `e` is in the table at row `r` and column identifier `c`.  This is accomplished by the function `make_row_assoc`.

+ Next apply the operations specified on the command line: sorting, then dropping rows, then "projecting" back to a `string list list` with the specified list of output columns.

+ Finally, pass the result to `output_table`.

A separate file, `select.ml` contains code to read the command-line arguments and call the `main` function in `tables.ml`:

+ `select` handles the job of understanding the command-line arguments
to our tool, converting the operations to a format `Tables.main` will understand and

+ evaluating the line below it, `let () = ...` is what causes all of the functions to be called with appropriate arguments.

The files as given will compile (with `ocamlc -o select str.cma tables.ml select.ml`) but the resulting program won't produce useful output until you fill in all of the incomplete functions, as instructed below.

**NOTE: If an error in one function causes your submission to fail to compile, _all_ of your automated testing scores will be 0.  If you cannot implement one of these functions in a way that will compile, leave the original version in place and put your best attempt in a comment.**

## Missing Functions

### 1. `table_of_stringlist`

The function `table_of_stringlist : string -> string list -> string list list` takes as input a delimiter `d` and a list of strings `l`, and converts each string in the list `l` into a list of strings using `make_row` using the first parameter `d` as a delimiter.  So `table_of_stringlist d [r1;r2;...;rN]` should evaluate to `[(make_row d r1); (make_row d r2); ...; (make_row d rN)]`.  Some example evaluations:

+ `table_of_stringlist "," ["a"]` should evaluate to `[["a"]]`

+ `table_of_stringlist "," ["a,b"]` should evaluate to `[["a"; "b"]]`

+ `table_of_stringlist "|" ["a|b|c"; "d"]` should evaluate to `[["a";"b";"c"]; ["d"]]`.

### 2. `make_row_assoc`

The function `make_row_assoc : bool -> string list list -> (string*string) list list` should translate a list of lists of strings into *row-associative form*:

 Some concrete evaluations:

+ `make_row_assoc false []` should evaluate to `[]`

+ `make_row_assoc false [[]]` should evaluate to `[[]]`

+ `make_row_assoc false [["a"]]` should evaluate to `[[("1","a")]]`

+ `make_row_assoc false [["a";"b"];["c"]]` should evaluate to `[[("1","a");("2","b")];[("1","c")]]`.

+ `make_row_assoc true [["c1";"c2"]; ["a";"b";"c"]; ["x"]]` should evaluate to `[[("c1","a");("c2","b")]; [("c1","x")]]`

Some considerations: you will probably find it easier to write separate functions to handle the conversion of each row with and without headers; perhaps you could use a single function to manage applying these separate functions to each row.

### 3. `row_get_column`

A useful helper function for the next two functions will be `row_get_column : string -> (string*string) list -> string`, which takes as input a column identifier `ci`, and an associative row of a table, and returns either the string in column `ci` if one is found, or the empty string `""` otherwise.  Some example evaluations:

+ `row_get_column "1" [("1","a")]` should evaluate to `"a"`.
+ `row_get_column "fall" [("winter","cold");("spring","rainy")]` should evaluate to `""`.
+ `row_get_column "pg" []` should evaluate to `""`.

### 4. `sort_assoc`

The function `sort_assoc : string -> (string*string) list list -> (string*string) list list` takes as input a column identifier and a row-associative table and should short the rows (in ascending order) according to the values in the given column.  So

+ `sort_assoc "2" [[("1","abc");("2","def")]; [("1","fed");("2","cba")]]` should evaluate to `[[("1","fed");("2","cba")];[("1","abc");("2","def")]]`
+ If a row doesn't have an entry for the column identifer, it should be treated as `""`, so `sort_assoc "3" [[("1","abc");("2","def")]; [("1","fed");("2","cba")]]` should simply evaluate to `[[("1","abc");("2","def")]; [("1","fed");("2","cba")]]`.

The `List.stable_sort` function will sort a list using a function that compares two elements, and returns a negative integer if the first is less than the second, 0 if they are equal, and a positive integer if the first is greater than the second.  The appropriate function to compare two *strings* is `compare`.  You will probably find it useful to write a separate function with type `string -> (string*string) list -> (string*string) list -> int` that can "eat" a column index and return a function that compares associative rows by that index.

**Note:** the sort here is lexicographic, so for instance `"23"` will come before `"8"`.  For a challenge, consider how you might modify `select` to allow numeric sorting as an option.

### 5. `cut_to_rows`

The function `cut_to_rows : int -> (string*string) list list -> (string*string) list list` should take an integer `k` and a row-associative table and return the first `k` rows of the table.  If `k` is greater than the length of the table, the entire table should be returned.  If `k` is negative, `cut_to_rows` should return an empty list.  Some example evaluations:

+ `cut_to_rows 1 [[("1","abc");("2","def")]; [("1","fed");("2","cba")]]` should evaluate to `[[("1","abc");("2","def")]]`.
+ `cut_to_rows (-1) [[("c1","d1")]]` should evaluate to `[]`.
+ `cut_to_rows 3 [[("dog","Fluffy")];[("dog","Blue")]]` should evaluate to `[[("dog","Fluffy")];[("dog","Blue")]]`.


### 6. `reassemble`

The function `reassemble : string list -> (string*string) list list -> string list list` will "reassemble" the table given a list of column indices to output and the row-associative representation of the table.  If a column index does not occur in an associative row, the corresponding position in the table row should be `""`.  Some example evaluations:

+ `reassemble ["3";"1"] [[("1","aa");("2","bb");("3","cc")]; [("1","dd");("2","ee");("3","ff")]]` should evaluate to `[["cc";"aa"]; ["ff";"dd"]]`.

+ `reassemble ["x";"x"] [[("x","1.0");("y","2.0")];[("x","4.0");("y","16.0")]]` should evaluate to `[["1.0";"1.0"];["4.0";"4.0"]]`.

+ `reassemble ["a"] [[("1","2")];[("1","3")]]` should evaluate to `[[""];[""]]`

## Testing

An important part of designing any software project is creating tests that ensure that the software behaves correctly, and thinking about "edge cases" that are either ambiguous in the specification or require special handling.  In the file `tabletest.ml`, you should construct a list of up to 25 boolean variables named `test1`, `test2`, and so on.  Each of these should test whether one of the functions in `tables.ml` returns some expected value, for example:

```ocaml
let test1 = (Tables.reassemble ["a"] [[("1","2")];[("1","3")]]) = [[""];[""]]
```

Every time you submit to github, your feedback file will include a list of whether each of these tests pass when compiled against the example solution.  For your final submission, you will be graded on (a) whether your own code passes all of the tests, (b) whether all tests are distinct (both from the examples in this document and each other) and (c) how extensively the tests cover the range of possible behavior in a possible solution.  

## Other considerations

In addition to satisfying the functional specifications given above, your code should be readable, with comments that explain what you're trying to accomplish.  It must compile with `ocamlc -c str.cma tables.ml`.  It must be committed in the `hw1` directory of your personal repository.  Finally, solutions that pay careful attention to resources like running time and stack space (e.g. using tail recursion wherever feasible) and code reuse are worth more than solutions that do not have these properties.


## Submission instructions and late grading requests

Once you are satisfied with the status of your submission in github, you can upload the files `tables.ml` and `tabletest.ml` to the "Homework 1" assignment on [Gradescope](https://www.gradescope.com/courses/159067).  We will run additional correctness testing to the basic feedback tests described here, and provide some manual feedback on the efficiency, readability, structure and comments of your code, which will be accessible in Gradescope once all homeworks have been graded.

**Late Grading**: Keep in mind that each student is allowed one "late grading request" this semester.  If you choose to use this request for this homework, then you should submit a file named `late_request.txt` by the submission deadline.  You will then have until 11:59pm (CST) on Thursday, October 1st to submit to the "Homework 1 Late" assignment.

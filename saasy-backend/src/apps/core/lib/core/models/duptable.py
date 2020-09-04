#!/usr/bin/env python3

import sys
import os
import re

test_base = "../../../test/models"
defaults = [".dup_template_model._ex", ".dup_template_test._exs", "DupTemplate"]

################################################################################
def main():
    [src, test, pascal_before] = defaults
    if len(sys.argv) == 3:
        [dst, pascal_after] = sys.argv[1:]

    elif len(sys.argv) == 5:
        [src, dst, pascal_before, pascal_after] = sys.argv[1:]
        test = None

    else:
        sys.exit("""

    Syntax: {cmd} {{path/to/src/model.ex}} {{path/to/dst/model.ex}} SnakeModelBefore SnakeModelAfter
            {cmd} {{path/to/dst/model.ex}} SnakeModelAfter

    If no src files provided it defaults to:

             path src      = {path_src}
             pascal before = {pascal_before}

    Tests are also included when no src file is provided, otherwise you need to do tests yourself.

    """.format(cmd=sys.argv[0], path_src=defaults[0], pascal_before=defaults[1]))

    convert_it(src, dst, pascal_before, pascal_after, "")
    convert_it(src, dst, pascal_before, pascal_after, "s")

    if test != None:
        convert_it(test, dst, pascal_before, pascal_after, "", test=True)

def cleanpath(path):
    if path[0:2] != "./":
        path = './' + path

    fbase = os.path.basename(path)
    try:
        [fbase, suffix] = fbase.rsplit(".", 1)
        if suffix not in ("ex", "exs", "_exs", "_ex"):
            raise ValueError("Sorry")
    except ValueError as err:
        sys.exit("unrecognized file suffix with: {}".format(path))

    snake = re.sub('_(test|model)$', '', fbase)
    snake = re.sub('^\.', '', snake)

    dir = os.path.dirname(path)

    # basedir, corename
    tsuffix = suffix
    if suffix[0] == "_":
        tsuffix = suffix[1:]
    return [dir, fbase, suffix, snake, os.path.join(test_base, dir)]
    #
    # if test:
    #     return [os.path.join(dir, base), base, suffix, os.path.join(test_base, dir)]
    # return [os.path.join(dir, base), base, suffix, dir]

def convert_it(src, dst, pascal_before, pascal_after, plus, test=False):
    [src_dir, src_fbase, src_suffix, src_snake, src_tdir] = cleanpath(src)
    [dst_dir, dst_fbase, dst_suffix, dst_snake, dst_tdir] = cleanpath(dst)

    snake_rx = re.compile(src_snake, flags=re.M)
    pascal_rx = re.compile(pascal_before, flags=re.M)

    path1 = os.path.join(src_dir, src_fbase) + plus + "." + src_suffix
    if test:
        path2 = os.path.join(dst_tdir, dst_fbase) + plus + "_test.exs"
        dst_dir = dst_tdir
    else:
        path2 = os.path.join(dst_dir, dst_fbase) + plus + "." + dst_suffix

    print("--{} => {}".format(path1, path2))
    print("  {} => {}".format(src_snake, dst_snake))
    print("  {} => {}".format(pascal_before, pascal_after))
    if not os.path.exists(path1):
        sys.exit("oops: {} doesn't exist".format(path1))
    if os.path.exists(path2):
        sys.exit("oops: {} already exists".format(path2))
    if not os.path.exists(dst_dir):
        #print("mkdir " + dst_dir)
        os.mkdir(dst_dir)

    with open(path1) as infile, open(path2, "w") as outfile:
        for line in infile:
            line = snake_rx.sub(dst_snake, line)
            line = pascal_rx.sub(pascal_after, line)
            outfile.write(line)

if __name__ == '__main__':
    main()

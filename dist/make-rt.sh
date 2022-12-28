#! /bin/bash

this_script="${0##*/}"
this_dir=`pwd`

# Command line.
app_name="${1}"
working_dir="${2}"
dist_dir="${3}"

usage() {
  echo "${this_script} is a helper for packaging standalone IDL applications."
  echo "    From an app name <app-name> and a directory <working-dir> that contains IDL"
  echo "    source (.pro) files, ${this_script} generates:"
  echo
  echo "        1. An IDL .run file compile-<app-name>.pro that contains commands"
  echo "            to compile all the source files and their transitive dependencies.".
  echo
  echo "        2. An IDL .run file make_rt_<app-name>.pro that contains the necessary"
  echo "            IDL commands to create the standalone application. When this .run"
  echo "            file is executed in IDL, it will produce among other things an"
  echo "            IDL .sav file in the working directory."
  echo
  echo "    These files will be created in a sub-directory named 'dist', under the"
  echo "    <working-dir>."
  echo
  echo "Usage: ${this_script} <app-name> <working-dir> <dist-dir>"
  echo
  echo "    app-name: name of the IDL application to build"
  echo
  echo "    working-dir: path to the top of the directory that holds the IDL .pro files."
  echo "        This directory is also where ${this_script} writes its output files."
  echo
  echo "    dist-dir: path to the directory under which IDL will create the distribution files."
  echo
  echo "    Example:"
  echo "        ./make-rt.sh steem ../idl/eevt_player ../../dist"
}

# Before calling, set list to be your array:
#   list=${your_array[@]})
# If you want quotes around the items, set quote, e.g.:
#   quote="'"
# If you want indentation, set indent before calling, e.g.:
#   indent="  "
#
cat_idl_list() {
  list=(`echo ${list[@]} | tr ' ' '\012' | sort | tr '\012' ' '`)
  result=""
  delim="${indent}${quote}"
  for item in ${list[@]}; do
    result+="${delim}${item}"
    delim="${quote}, $\n${indent}${quote}"
  done

  echo -n "${result}${quote}"
}

# Process command line.
if test "${app_name}" = "-h" -o "${app_name}" = "--help"; then
  usage
  exit 0
fi

if test "${app_name}" = ""; then
  usage >&2
  echo "${this_script}: missing first argument, base name of output files (.pro and .sav)." >&2
  exit 1
fi

if test "${working_dir}" = ""; then
  usage >&2
  echo "${this_script}: missing second argument, name of working directory." >&2
  exit 1
elif test ! -d "${working_dir}"; then
  usage >&2
  echo "${this_script}: second argument ${working_dir} is not a directory." >&2
  exit 1
fi

working_dir=`cd "${working_dir}"; pwd`

output_dir="${working_dir}/dist"
if test -d "${output_dir}"; then
  :
elif test -e "${output_dir}"; then
  echo "${this_script}: output area ${output_dir} exists but is not a directory" >&2
  exit 1
else
  mkdir -p "${output_dir}"
  if test $? -ne 0; then
    echo "${this_script}: unable to create output directory ${output_dir}" >&2
    exit 1
  fi
fi

if test "${dist_dir}" = ""; then
  usage >&2
  echo "${this_script}: missing third argument, name of the distribution (IDL output) directory." >&2
  exit 1
elif test -e "${dist_dir}" -a ! -d "${dist_dir}"; then
  usage >&2
  echo "${this_script}: third argument ${dist_dir} exists but is not a directory." >&2
  exit 1
fi

# Derived variables.
compile_file_name="compile_${app_name}.pro"
compile_file="${output_dir}/${compile_file_name}"
make_rt_file_name="make_rt_${app_name}.pro"
make_rt_file="${output_dir}/${make_rt_file_name}"
sav_file="${output_dir}/${app_name}_app.sav"

# Find the pro files, but exclude the .run file that this script writes
# (that creates the dist files in IDL).
files=`find "${working_dir}" -name '*.pro' | grep -v "${compile_file_name}$" | grep -v "${make_rt_file_name}$"`

if test "${files}" = ""; then
  echo "${this_script}: no pro files found in dir ${working_dir}" >&2
  exit 1
fi

if test `echo $files | grep -c "${app_name}_app.pro"` -eq 0; then
  echo "${this_script}: missing required top-level launch pro file ${app_name}_app.pro" >&2
  exit 1
fi

classes=()
functions=()
pros=()
methods=()
for file in ${files}; do
  # Find classes.
  matches=(`sed -n 's:^ *pro  *::ip' "${file}" | sed -n 's:__define.*::ip'`)
  classes+=(${matches[@]})

  # Find pure functions (exclude ::).
  matches=(`sed -n 's:^ *function  *::ip' "${file}" | sed 's:,.*::' | grep -v '::'`)
  functions+=(${matches[@]})

  # Find pure pros (exclude ::).
  matches=(`sed -n 's:^ *pro  *::ip' "${file}" | sed 's:,.*::' | grep -v '__define' | grep -v '::'`)
  pros+=(${matches[@]})
  
  # Find function-flavored methods (include ::).
  # Note that the methods array is only used in commented-out code, strictly not necessary.
  matches=(`sed -n 's:^ *function  *::ip' "${file}" | sed 's:,.*::' | grep '::'`)
  methods+=(${matches[@]})
  
  # Find pro-flavored methods (include ::).
  # Note that the methods array is only used in commented-out code, strictly not necessary.
  matches=(`sed -n 's:^ *pro  *::ip' "${file}" | sed 's:,.*::' | grep -v '__define' | grep '::'`)
  methods+=(${matches[@]})
done

if test ${#classes[@]} -eq 0 -a ${#functions[@]} -eq 0 -a ${#pros[@]} -eq 0 -a ${#methods[@]} -eq 0; then
  echo "${this_script}: bailing out: no classes, functions or procedures found in ${working_dir}" >&2
  exit 1
fi

# At this point everything *should* work, so delete/recreate the dist directory.
if test -d "${dist_dir}"; then
  rm -rf "${dist_dir}"
elif test -e "${dist_dir}"; then
  echo "${this_script}: distribution directory ${dist_dir} exists but is not a directory" >&2
  exit 1
fi
mkdir -p "${dist_dir}"
if test $? -ne 0; then
  echo "${this_script}: unable to create distribution directory ${dist_dir}" >&2
  exit 1
fi
dist_dir=`cd "${dist_dir}"; pwd`

quote="'"
indent="    "

list=(${classes[@]})
class_array=`cat_idl_list`

list=(${functions[@]})
function_array=`cat_idl_list`

list=(${pros[@]})
pro_array=`cat_idl_list`

list=`echo "(${methods[@]})" | tr ' ' '\012' | sort`
method_array=`cat_idl_list`

echo -e "resolve_all, $\n  class = [ $\n${class_array} ], $\n  resolve_function = [ $\n${function_array} ], $\n  resolve_procedure = [ $\n${pro_array} ]\n\nend" > "${compile_file}"

# echo -e "save, $\n${function_array}, $\n${pro_array}, $\n${method_array}, $\n    /routines, $\n    filename='${sav_file}'" > "${make_rt_file}"
# echo -e "\nmake_rt, '${app_name}', '${dist_dir}', savefile='${sav_file}'" >> "${make_rt_file}"
# echo -e "\nend" >> "${make_rt_file}"

echo -e "save, /routines, $\n    filename='${sav_file}' \n\nmake_rt, '${app_name}', '${dist_dir}', $\n    savefile='${sav_file}', $\n    /overwrite\n\nend" > "${make_rt_file}"


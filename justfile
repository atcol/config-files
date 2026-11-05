# Update every submodule to its tracked remote branch (remote HEAD by default).
# Review and commit the changed submodule pins after running this recipe.
update-submodules:
    git submodule update --init --remote --recursive

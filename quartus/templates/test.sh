TEMPLATE=DefaultTemplate
PROJECT=NewTemplate
rename $TEMPLATE $PROJECT $(find $PWD -name "$TEMPLATE.*")

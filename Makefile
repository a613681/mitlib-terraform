configs = global $(wildcard shared/*) $(wildcard apps/*)

all: $(configs)

$(configs): FORCE
	## The grep bit can be removed once the full repo has been upgraded to 0.12.
	## There is apparently a bug in 0.12 that prevents us from being able to run
	## validate (https://github.com/hashicorp/terraform/issues/21761). For now,
	## we'll disable the validate and at least run fmt.
	cd $@ && \
		if grep -q -P -r --exclude-dir '.*' "required_version\s*=\s*\">=\s*0\.12\""; \
		then terraform fmt -check -recursive; fi
		#then terraform init -backend=false && terraform validate; fi

FORCE:

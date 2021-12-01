R=`tput setaf 1`
G=`tput setaf 2`
Y=`tput setaf 3`
B=`tput setaf 4`
NC=`tput sgr0`

# ------- Parameters
$(eval DOM ?= asprilo)
$(eval APP ?= afw)
$(eval MODELS ?= 1)
$(eval FORCE_TRANSLATE ?= 1)
$(eval JOIN ?= 0)
$(eval NAME_INSTANCE = $(basename $(notdir $(INSTANCE))))
$(eval PATH_OUT = ./outputs/$(DOM)/$(APP)/$(CONSTRAINT)/$(NAME_INSTANCE))
$(eval PATH_TO_TELINGO = benchmarks/telingo)
$(eval PATH_FROM_TELINGO = ../..)
$(eval PATH_INPUT = dom/$(DOM)/temporal_constraints/$(CONSTRAINT))
ZSH_RESULT:=$(shell mkdir -p $(PATH_OUT))
$(eval EXTRA = dom/$(DOM)/extra.lp)
$(eval PY_PARAMS ?= )

# ------- Files needed for each appproach RUN_APP_FILES_$APP
$(eval RUN_APP_FILES_afw = encodings/automata_run/run.lp dom/$(DOM)/glue.lp)
$(eval RUN_APP_FILES_afw2 = encodings/automata_run/run2w.lp dom/$(DOM)/glue.lp)
# $(eval RUN_APP_FILES_telingo = dom/elevator/encoding.lp )
$(eval RUN_APP_FILES_dfa-mso = encodings/automata_run/run.lp)
$(eval RUN_APP_FILES_dfa-stm = encodings/automata_run/run.lp)
$(eval RUN_APP_FILES_nfa = encodings/automata_run/run.lp)
$(eval RUN_APP_FILES_nfa-afw = encodings/automata_run/run.lp dom/$(DOM)/glue.lp)


# ------- Files needed for each dommain RUN_DOM_FILES_$DOM
$(eval RUN_DOM_FILES_asprilo-md = benchmarks/asprilo/asprilo-abstraction-encodings/encodings/torsten/md/action-MD.lp benchmarks/asprilo/asprilo-abstraction-encodings/encodings/torsten/md/goal-MD.lp benchmarks/asprilo/asprilo-abstraction-encodings/encodings/torsten/md/output-M.lp benchmarks/asprilo/asprilo-abstraction-encodings/asprilo/misc/augment-md-to-m.lp $(RUN_FILES))
$(eval RUN_DOM_FILES_asprilo-abc = benchmarks/asprilo/asprilo-abstraction-encodings/asprilo-encodings/abc/encoding-a.lp benchmarks/asprilo/asprilo-abstraction-encodings/asprilo-encodings/abc/quantities.lp benchmarks/asprilo/asprilo-abstraction-encodings/asprilo-encodings/control/highways.lp $(RUN_FILES))
$(eval RUN_DOM_FILES_elevator = dom/elevator/encoding.lp $(RUN_FILES))
$(eval RUN_DOM_FILES_hanoi = dom/hanoi/encoding.lp $(RUN_FILES))
$(eval RUN_DOM_FILES_river = dom/river/encoding.lp $(RUN_FILES))
$(eval RUN_DOM_FILES_yale = dom/yale/encoding.lp $(RUN_FILES))
$(eval RUN_DOM_FILES_test = $(RUN_FILES))
$(eval RUN_DOM_FILES_nc = $(RUN_FILES))

# ------- Files needed to translate each dommain TRANSLATE_FILES_$DOM
$(eval TRANSLATE_FILES_asprilo-abc = benchmarks/asprilo/asprilo-abstraction-encodings/asprilo-encodings/input.lp $(TRANSLATE_FILES))
$(eval TRANSLATE_FILES_asprilo-md = benchmarks/asprilo/asprilo-abstraction-encodings/asprilo-encodings/input.lp $(TRANSLATE_FILES))
$(eval TRANSLATE_FILES_elevator = $(TRANSLATE_FILES))
$(eval TRANSLATE_FILES_test = $(TRANSLATE_FILES))


ifeq ("$(wildcard $(EXTRA))","")
    $(eval EXTRA = )
endif

clean:
	rm -rf outputs/*
	(cd benchmarks ; make clean)


viz-tex:
	@ printf "$BVisualizing APP=$(APP) DOM=$(DOM) CONSTRAINT=$(CONSTRAINT)$ INSTANCE=$(NAME_INSTANCE) HORIZON=$(HORIZON) $(NC)\n"
	
	python scripts/viz.py --app=$(APP) --dom=$(DOM) --instance=$(NAME_INSTANCE) --constraint=$(CONSTRAINT) --instance_path=$(INSTANCE) --latex 
	

	@ printf "$BCompiling latex...$(NC)\n"

	pdflatex -halt-on-error -output-directory $(PATH_OUT) $(PATH_OUT)/$(APP)_automata.tex > /dev/null 2>&1

	@ printf "$(G)Pdf saved in $(PATH_OUT)/$(APP)_automata.pdf $(NC)\n";\

	open $(PATH_OUT)/$(APP)_automata.pdf

viz-png:
	@ printf "$BVisualizing APP=$(APP) DOM=$(DOM) CONSTRAINT=$(CONSTRAINT)$ INSTANCE=$(NAME_INSTANCE) HORIZON=$(HORIZON) $(NC)\n"
	
	python scripts/viz.py --app=$(APP) --dom=$(DOM) --instance=$(NAME_INSTANCE) --constraint=$(CONSTRAINT) --instance_path=$(INSTANCE)
	
	@ printf "$(G)PNG saved in $(PATH_OUT) $(NC)\n";\

	open $(PATH_OUT)/$(APP)_automata.png


tests:
	@ printf "$(B)Running 'del' tests...$(NC)"
	@ python -m unittest tests.del_test

stats:
	tail -32 $(PATH_OUT)/plan_h-$(HORIZON)_n-$(MODELS).txt

translate:

	@ printf "$BTranslating APP=$(APP) DOM=$(DOM) CONSTRAINT=$(CONSTRAINT) INSTANCE=$(NAME_INSTANCE) $(NC)\n"

	@ make translate-$(APP) 

	@if [ -s $(PATH_OUT)/$(APP)_automata.lp ]; then\
		printf "$(G)Translation to $(APP)  successfull. \nOutput saved in $(PATH_OUT)/$(APP)_automata.lp $(NC)\n";\
	else \
		printf "$(R) Translation to $(APP) failed no output automata\n";\
		exit 1;\
    fi;

empty:

	@make translate;

	clingo $(PATH_OUT)/$(APP)_automata.lp encodings/empty.lp --warn=none


run:

	@ printf "$BRunning APP=$(APP) DOM=$(DOM) CONSTRAINT=$(CONSTRAINT)$ INSTANCE=$(NAME_INSTANCE) HORIZON=$(HORIZON) $(NC)\n"

	@rm -f $(PATH_OUT)/plan_h-$(HORIZON)_n-$(MODELS).txt

	clingo $(PATH_OUT)/$(APP)_automata.lp $(INSTANCE) $(RUN_APP_FILES_$(APP)) $(RUN_DOM_FILES_$(DOM)) $(EXTRA) -c horizon=$(HORIZON) -n $(MODELS) | tee $(PATH_OUT)/plan_h-$(HORIZON)_n-$(MODELS).txt 

translate-run:

	@if [ "$(APP)" = "nc" ]; then\
		echo "$(Y)No constrain option$(NC)";\
		clingo --stats $(INSTANCE) $(RUN_DOM_FILES_$(DOM)) -c horizon=$(HORIZON) -n $(MODELS) | tee $(PATH_OUT)/plan_h-$(HORIZON)_n-$(MODELS).txt;\
		exit 1;\
	fi
	@if [ "$(FORCE_TRANSLATE)" = "1" ]; then \
		make translate;\
	elif [ "$(APP)" = "telingo" ]; then\
		make translate;\
	else\
		if [ -s $(PATH_OUT)/$(APP)_automata.lp ]; then\
			echo "$(Y)Skipping translation$(NC)";\
		else\
			echo "$(Y)Making translation since file is missing$(NC)";\
			make translate;\
		fi;\
	fi

	# @ make translate
	
	@ make run


######################  AFW ########################

translate-afw:

	@if [ "$(APP)" = "afw" ]; then echo ""; else  echo "$(R)Inconsistency APP should be afw$(NC)"; fi

	@ printf "$BReifying constraint... $(NC)\n"

	gringo encodings/translations/grammar.lp $(PATH_INPUT).lp $(INSTANCE) $(TRANSLATE_FILES_$(DOM)) --output=reify > $(PATH_OUT)/reified.lp 


	@if grep theory_atom $(PATH_OUT)/reified.lp -q; then\
		printf "$(G)Reification successfull $(NC)\n";\
	else \
		printf "$(R)Reification failed, theory was not reified\n";\
		exit 1;\
    fi;

	@ printf "$(B)Translating.... $(NC)\n"
	clingo $(PATH_OUT)/reified.lp ./encodings/translations/ldlf2afw.lp -n 0 --outf=0 -V0 --out-atomf=%s. --warn=none | head -n1 | tr ". " ".\n"  > $(PATH_OUT)/afw_automata.lp


	@if [ "$(JOIN)" = "1" ]; then \
		printf "$(Y)Joining afw... $(NC)\n";\
		clingo encodings/translations/joinafw.lp $(PATH_OUT)/afw_automata.lp -n 0 --outf=0 -V0 --out-atomf=%s. --warn=none  | head -n1 | tr ". " ".\n"  > $(PATH_OUT)/tmp_afw_automata.lp ;\
		cat $(PATH_OUT)/tmp_afw_automata.lp >   $(PATH_OUT)/afw_automata.lp;\
		rm $(PATH_OUT)/tmp_afw_automata.lp;\
		printf "$(G)Join afw successfull $(NC)\n";\
	fi;


######################  AFW2 ########################

translate-afw2:

	@if [ "$(APP)" = "afw2" ]; then echo ""; else  echo "$(R)Inconsistency APP should be afww$(NC)"; fi

	@ printf "$BReifying constraint... $(NC)\n"

	gringo encodings/translations/grammar.lp $(PATH_INPUT).lp $(INSTANCE) $(TRANSLATE_FILES_$(DOM)) --output=reify > $(PATH_OUT)/reified.lp 


	@if grep theory_atom $(PATH_OUT)/reified.lp -q; then\
		printf "$(G)Reification successfull $(NC)\n";\
	else \
		printf "$(R)Reification failed, theory was not reified\n";\
		exit 1;\
    fi;

	@ printf "$(B)Translating.... $(NC)\n"
	clingo $(PATH_OUT)/reified.lp ./encodings/translations/ldlf22afw.lp -n 0 --outf=0 -V0 --out-atomf=%s. --warn=none | head -n1 | tr ". " ".\n"  > $(PATH_OUT)/afw2_automata.lp





######################  TELINGO ########################

translate-telingo:
	$(eval TELINGO_TRANSLATE_FILES = )

	$(foreach n,$(TRANSLATE_FILES_$(DOM)),$(if $(n),$(eval TELINGO_TRANSLATE_FILES=$(TELINGO_TRANSLATE_FILES) $(PATH_FROM_TELINGO)/$(n) )))

	(cd benchmarks/telingo ; python telingo/program_observer.py --h=$(HORIZON) --out-file=$(PATH_FROM_TELINGO)/$(PATH_OUT)/telingo_automata.lp --extra-files="$(TELINGO_TRANSLATE_FILES)" --choices-file=$(PATH_FROM_TELINGO)/dom/$(DOM)/telingo_choices.lp --instance-file=$(PATH_FROM_TELINGO)/$(INSTANCE) --constraint-file=$(PATH_FROM_TELINGO)/$(PATH_INPUT).lp )


######################  DFA ########################


translate-dfa-mso:
	

	python ./scripts/translater.py --input=ldlf --app=dfa-mso --out-file=$(PATH_OUT)/dfa-mso_automata.lp --in-files='./$(PATH_INPUT).lp $(TRANSLATE_FILES_$(DOM)) $(INSTANCE)' $(PY_PARAMS)


translate-dfa-stm:
	

	python ./scripts/translater.py --input=ldlf --app=dfa-stm --out-file=$(PATH_OUT)/dfa-stm_automata.lp --in-files="./$(PATH_INPUT).lp $(TRANSLATE_FILES_$(DOM)) $(INSTANCE)" $(PY_PARAMS)

######################  NFA ########################


translate-nfa:
	
	@ make translate-afw APP=afw CONSTRAINT=$(CONSTRAINT) INSTANCE=$(INSTANCE) DOM=$(DOM) TRANSLATE_FILES=$(TRANSLATE_FILES_$(APP)) $(PY_PARAMS)

	python ./scripts/translater.py --input=afw --app=nfa --out-file=$(PATH_OUT)/nfa_automata.lp --in-files=./outputs/$(DOM)/afw/$(CONSTRAINT)/$(NAME_INSTANCE)/afw_automata.lp

translate-nfa-afw:
	
	@ make translate-afw APP=afw CONSTRAINT=$(CONSTRAINT) INSTANCE=$(INSTANCE) DOM=$(DOM) TRANSLATE_FILES=$(TRANSLATE_FILES_$(APP)) $(PY_PARAMS)

	clingo ./outputs/$(DOM)/afw/$(CONSTRAINT)/$(NAME_INSTANCE)/afw_automata.lp ./encodings/translations/afw2nfa.lp -n 0 --outf=0 -V0 --out-atomf=%s. --warn=none | head -n1 | tr ". " ".\n"  > $(PATH_OUT)/nfa-afw_automata.lp

###################### ASPRILO EXTRA ###################

viz-asprilo:
	sed -n "4,5p" $(PATH_OUT)/plan_h-$(HORIZON)_n-$(MODELS).txt | viz


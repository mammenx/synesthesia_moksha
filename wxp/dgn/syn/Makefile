PRJ_NAME=syn_moksha

clean :
	echo "Cleaning Synthesis workspace"
	rm -rf .qsys_edit db greybox_tmp incremental_db hc_output
	rm -rf *.xml *.qdf *.pin *.dpf *.htm *.txt *.rpt *.log *.summary *.done *.smsg

map :
	echo "Starting Quartus Map for Project:$(PRJ_NAME)"
	quartus_map --read_settings_files=on --write_settings_files=off $(PRJ_NAME) -c $(PRJ_NAME)

fit :
	echo "Starting Quartus Fit for Project:$(PRJ_NAME)"
	quartus_fit --read_settings_files=off --write_settings_files=off $(PRJ_NAME) -c $(PRJ_NAME)

asm :
	echo "Starting Quartus Assembler for Project:$(PRJ_NAME)"
	quartus_asm --read_settings_files=off --write_settings_files=off $(PRJ_NAME) -c $(PRJ_NAME)

sta :
	echo "Starting Quartus STA for Project:$(PRJ_NAME)"
	quartus_sta $(PRJ_NAME) -c $(PRJ_NAME)

syn : map fit asm sta

qar :
	rm -rf $(PRJ_NAME).qar $(PRJ_NAME).qarlog
	echo "Archiving Quartus Project:$(PRJ_NAME)"
	quartus_sh --archive $(PRJ_NAME)

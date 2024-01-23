output_name = force_regs.random.ucli

$(output_name): force_regs.ucli
	awk 'BEGIN{srand();}{if ($$1 != "") { print $$1,$$2,$$3,int(rand()*2)}}' $< > $@

clean:
	rm -f $(output_name)

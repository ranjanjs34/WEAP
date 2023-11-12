#! /usr/bin/bash
clear
echo -e "                 ---------------------------------------                 "
echo -e "=================- WEAP: Whole Exome Analysis Pipeline -================="
echo -e "                 ---------------------------------------               \n"
echo -e "Developer       : "
echo -e "                  "
echo -e "Institution     : "
echo -e "                  "
echo -e "========================================================================="

./bin/weap_bin

clear
cat ./about
echo "Press ENTER to start the analysis."
read enter

name=$(head -2 ./weap.temp/weap_user|tail -1)
My_output=$(tail -1 ./weap.temp/weap_user)
mutation=$(head -1 ./weap.temp/mutation.type)
mode=$(head -2 ./weap.temp/mutation.type | tail -1 )
build_pon=$(tail -1 ./weap.temp/mutation.type)
#parallel_job=$(($(nproc) / ))
parallel_job=4
echo "Analysis started at: "$(LANG='en_US.UTF-8'; date)


if [ $mutation == g ]
then
	
	echo -e "Alignment started at " $(LANG='en_US.UTF-8'; date)
	echo -e "Analysis started at " $(LANG='en_US.UTF-8'; date)>analysis_time.txt
	echo -e "Alignment started at " $(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	cat $My_output/WEAP_output_$name/log/1_align.txt| parallel --bar -j 4  {}
	echo -e "Alignment Finished at " $(LANG='en_US.UTF-8'; date)>>Germline_time.txt

	
	echo -e "Convertion of SAM to BAM started at "$(LANG='en_US.UTF-8'; date)
	echo -e "Convertion of SAM to BAM started at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	cat $My_output/WEAP_output_$name/log/2_sam2bam.txt | parallel --bar -j 4  {}
        echo -e "Convertion of SAM to BAM Finished at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt

	echo -e "Removing SAM files to save Disk space at "$(LANG='en_US.UTF-8'; date)
	rm -rf $My_output/WEAP_output_$name/output/sam

	echo -e "Sorting BAM files started at "$(LANG='en_US.UTF-8'; date)
	echo -e "Sorting BAM files started at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	cat $My_output/WEAP_output_$name/log/3_bam_sort.txt | parallel --bar -j 4  {}
        echo -e "Sorting BAM files finished  at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt




	echo -e "Creating BAM indices at "$(LANG='en_US.UTF-8'; date)
	cat $My_output/WEAP_output_$name/log/_bam_index.txt | parallel --bar -j 4  {}

	
	
	echo -e "Running Picard for duplicate removal at "$(LANG='en_US.UTF-8'; date)
	echo -e "Running Picard for duplicate removal at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	cat $My_output/WEAP_output_$name/log/5_Picard.txt | parallel --bar -j 4   {}
	echo -e "Finished Picard for duplicate removal at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 10



	echo -e "Running BQSR "$(LANG='en_US.UTF-8'; date)
	echo -e "Running BQSR "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	cat $My_output/WEAP_output_$name/log/6_BQSR_BAM.txt | parallel --bar -j 4 {}
	echo -e "Finished BQSR "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 10


	
	echo -e "Running GATK HaplotypeCaller for Germline Variant Calling at "$(LANG='en_US.UTF-8'; date)
	echo -e "Running HaplotypeCaller "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	cat $My_output/WEAP_output_$name/log/7_HaplotypeCaller_gvcf.txt | parallel --bar -j 4 {}
        echo -e "Finished HaplotypeCaller "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 10
	
	
		
	echo -e "Combining gVCFs at "$(LANG='en_US.UTF-8'; date)
	echo -e "Combining gVCFs at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sh $My_output/WEAP_output_$name/log/Combined_gVCF.sh
	echo -e "Combining gVCFs finished at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 10
	
	
	
	echo -e "Genytyping gVCF at "$(LANG='en_US.UTF-8'; date)
	echo -e "Genytyping gVCF at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sh $My_output/WEAP_output_$name/log/Genotype.gVCF.sh
	echo -e "Genytyping gVCF finished at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 10
	
	
	echo -e "Generating Variant Quality Score Recalibration Model at "$(LANG='en_US.UTF-8'; date)
	echo -e "VQSR starts at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sh $My_output/WEAP_output_$name/log/vqsr.sh
	
	sleep 10
	
	
	echo -e "Applying Variant Quality Score Recalibration Model at "$(LANG='en_US.UTF-8'; date)
	sh $My_output/WEAP_output_$name/log/apply_vqsr.sh
	echo -e "VQSR stop at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 10
	
	
	echo -e "Running Variant Filtration at "$(LANG='en_US.UTF-8'; date)
	echo -e "Running Variant Filtration at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sh $My_output/WEAP_output_$name/log/Germline_VariantFiltration.sh
	echo -e "Finished Variant Filtration at "$(LANG='en_US.UTF-8'; date)>>Germline_time.txt
	sleep 5
	
		
	
	echo -e "Running Variant Filtration Distribution at "$(LANG='en_US.UTF-8'; date)
	sh $My_output/WEAP_output_$name/log/Variant_Filter_Distribution.sh
	sleep 5
	
	
	
	echo -e "Getting Passed Variants at "$(LANG='en_US.UTF-8'; date)
	sh $My_output/WEAP_output_$name/log/Passed_Variants.sh
	sleep 5
	
	
	
		
	echo -e "Preparing for Annovar at "$(LANG='en_US.UTF-8'; date)
	sh $My_output/WEAP_output_$name/log/Annovar_Input.sh
	sleep 5

elif [ $mutation == s ]
then
	if [ $build_pon == y ]
	then
		echo "Skipping Panal of Normal Creation \n\n"                                                                                     
	elif [ $build_pon == n ]
	then
	
		#Aligning and Variant alling from PoN
		echo "Generating PoN SAMs:"
		echo -e "Generating PoN SAMs starts at "$(LANG='en_US.UTF-8'; date)>pon_time.txt
		cat $My_output/WEAP_output_$name/log/pon_align.txt | parallel --bar -j 4  {}
		echo -e "Generating PoN SAMs Finished at "$(LANG='en_US.UTF-8'; date)>>pon_time.txt

		sleep 15
		clear
		
		
		echo "Converting PoN SAMs to BAMs:"
		echo -e "Convertion of PoN SAM to BAM starts at "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		cat $My_output/WEAP_output_$name/log/pon_sam2bam.txt | parallel --bar -j 4  {}
		echo -e "Convertion of PoN SAM to BAM starts at "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		
		sleep 15
		clear
		
		
		echo "Sorting PoN BAMs:"
		echo -e "Sorting PoN BAM by cordinates Starts at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		cat $My_output/WEAP_output_$name/log/pon_bam_sort.txt | parallel --bar -j 4  {}
		echo -e "Sorting PoN BAM by cordinates Finished at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		
		sleep 15
		clear
		
		
		echo "Indexing PoN BAMs:"
		cat $My_output/WEAP_output_$name/log/pon_bam_index.txt | parallel --bar -j 4  {}
		
		sleep 15
		clear
		
		
		echo "Removing Duplicates from PoN BAMs:"
		echo -e "Duplicate Removal from PoN BAMs starts at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		cat $My_output/WEAP_output_$name/log/pon_Picard.txt | parallel --bar -j 4  {}
		echo -e "Duplicate Removal from PoN BAMs Finished at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		
		sleep 15
		clear
		
		
		
		echo "Calling PoN VCF:"
		echo -e "Calling PoN VCF starts at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		cat $My_output/WEAP_output_$name/log/pon_vcf.txt | parallel --bar -j 4  {}
		echo -e "Calling PoN VCF finished at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		echo -e "\n\n\n"
		sleep 15
		clear
		
		
		export export TILEDB_DISABLE_FILE_LOCKING=1
		clear
		sleep 5
		
		
		echo "Generating PoN Database:"
		sleep 15
		sh $My_output/WEAP_output_$name/log/pon_db.sh
		clear
		sleep 15
		
		
		
		echo "Generating PoN VCF:"
		sh $My_output/WEAP_output_$name/log/PoN.generate.sh
		echo -e "Calling PoN VCF finished at: "$(LANG='en_US.UTF-8'; date)>>pon_time.txt
		sleep 10
	fi
	clear
	
	
	#Aligning Tumor Samples
	echo -e "Generating SAMs from Tumor:\n"
	echo -e "Generating SAMs from Tumor starts at "$(LANG='en_US.UTF-8'; date)>tom_time.txt
	cat $My_output/WEAP_output_$name/log/align_tumor.txt | parallel --bar -j 4  {}
	echo -e "Generating SAMs from Tumor finished at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	echo -e "\n\n\n"
	sleep 15
	
	
	echo "Convertion of Tumor SAM to BAM:"
	echo -e "Converstion of Tumor SAMs to BAM starts at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	cat $My_output/WEAP_output_$name/log/sam2bam_tumor.txt | parallel --bar -j 4 {}
	echo -e "Converstion of Tumor SAMs to BAM finished at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	
	sleep 15
	
	
	echo "Sorting Tumor BAM:"
	echo -e "sorting of tumor BAMs starts at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	cat $My_output/WEAP_output_$name/log/bam_sort_tumor.txt | parallel --bar -j 4 {}
	echo -e "sorting of tumor BAMs finished at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	echo -e "\n\n\n"
	sleep 15
	
	
	cat $My_output/WEAP_output_$name/log/bam_index_tumor.txt | parallel --bar -j 4 {}
	echo -e "\n\n\n"
	sleep 15
	
	
	echo "Removing Duplicate reads from Tumor BAMs:"
	echo -e "Duplicate removal from tumor BAMs starts at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	cat $My_output/WEAP_output_$name/log/Picard_tumor.txt | parallel --bar  -j 4 {}
	echo -e "Duplicate removal from tumor BAMs finished at "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
	sleep 10
	clear


	if [ $mode == TOM ]
	then
		echo "Variant calling using Tumor only Mode started at: "$(LANG='en_US.UTF-8'; date)
		echo "Variant calling using Tumor only Mode started at: "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
		#Variant calling TOM Mode.	
		cat $My_output/WEAP_output_$name/log/Mutect2_VCF_call_TOM_tumor.txt | parallel --bar -j 4 {}
		echo "Variant calling using Tumor only Mode finished at: "$(LANG='en_US.UTF-8'; date)>>tom_time.txt
		clear
		sleep 10
	
	
	
	elif [ $mode == TWM ]
	then
		echo -e "Generating SAMs from matched normal:\n"
		echo -e "Generating SAMs from matched normal starts at "$(LANG='en_US.UTF-8'; date)>twm_time.txt
		cat $My_output/WEAP_output_$name/log/align_AN.txt | parallel --bar -j 4  {}
		echo -e "Generating SAMs from matched normal finished at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		
		sleep 15
		clear
		
		
		
		echo "Convertion of matched normal SAM to BAM:"
		echo -e "Converstion of matched normal SAMs to BAM starts at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		cat $My_output/WEAP_output_$name/log/sam2bam_AN.txt | parallel --bar -j 4 {}
		echo -e "Converstion of matched normal SAMs to BAM finished at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		
		sleep 15
		clear
		
		
		echo "Sorting of matched normal BAM:"
		echo -e "Sorting of matched normal  BAM starts at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		cat $My_output/WEAP_output_$name/log/bam_sort_AN.txt | parallel --bar -j 4 {}
		echo -e "Sorting of matched normal BAM finished at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		
		sleep 15
		clear
		
		
		cat $My_output/WEAP_output_$name/log/bam_index_AN.txt | parallel --bar -j 4 {}
		
		sleep 15
		clear
		
		
		echo "Duplicate Removal from Matched normal BAM:"
		echo -e "Duplicate Removal from Matched normal BAM starts at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		cat $My_output/WEAP_output_$name/log/Picard_AN.txt | parallel --bar -j 4 {}
		echo -e "Duplicate Removal from Matched normal BAM finished at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		
	        sleep 15
	        clear
	        
	        #variant calling TWM Mode
	        echo "Variant calling TWM Mode:"
	        echo -e "Variant calling TWM Mode at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt	
		cat $My_output/WEAP_output_$name/log/Mutect2_TWM.txt | parallel --bar -j 4 {}
		echo -e "Variant calling TWM Mode finished at "$(LANG='en_US.UTF-8'; date)>>twm_time.txt
		sleep 8
		clear
	fi
fi

#Somatic Variant Filtration:
if [ $mutation == s ]
then
	cat $My_output/WEAP_output_$name/log/SomaticVariantFiltration.txt | parallel --bar -j 4  {}
	echo -e "Getting Paased Variants at "$(LANG='en_US.UTF-8'; date)
	cat $My_output/WEAP_output_$name/log/8_passed_variant.txt| parallel --bar -j 4  {}
	sleep 10
	
	
	echo -e "Preparing for input data for Annovar at "$(LANG='en_US.UTF-8'; date)
	cat $My_output/WEAP_output_$name/log/9_annovar_input.txt | parallel --bar -j 4  {}
fi

#Annotation of Germline and Somatic Variants:
if [ $mutation == g ]
then 
	echo -e "Germline Variant Annotation started at "$(LANG='en_US.UTF-8'; date)
	echo -e "Germline Variant Annotation started at "$(LANG='en_US.UTF-8'; date)>Germline_Annotation_time.txt
	cat $My_output/WEAP_output_$name/log/10_Annotation.txt | parallel --bar -j 4  {}
	echo -e "Germline Variant Annotation finished at "$(LANG='en_US.UTF-8'; date)>>Germline_Annotation_time.txt


elif [ $mutation == s ]
then
	echo -e "Somatic Variant Annotation started at "$(LANG='en_US.UTF-8'; date)
	echo -e "Somatic Variant Annotation started at "$(LANG='en_US.UTF-8'; date)>Somatic_Annotation_time.txt
	cat $My_output/WEAP_output_$name/log/10_Annotation.txt | parallel --bar -j 4  {}
	echo -e "Somatic Variant Annotation finished at "$(LANG='en_US.UTF-8'; date)>>Somatic_Annotation_time.txt
fi
sleep 10

clear
echo -e "Arranging the Annotated Files at "$(LANG='en_US.UTF-8'; date)
chmod +x $My_output/WEAP_output_$name/log/11_Downstream_analysis.sh
sh $My_output/WEAP_output_$name/log/11_Downstream_analysis.sh
clear
#echo -e "Preparing for IGV reports at "$(LANG='en_US.UTF-8'; date)
#cat $My_output/WEAP_output_$name/log/12_chr_pos_patho_var.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/13_bcf_tools.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/1_make_vcf_searchable.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/15_vcf_header.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/16_vcf.2.viz.conv.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/17_vcf.2.viz_gz.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/18_tabix_vcf.2.viz_gz.txt| parallel --bar -j 4   {}
#cat $My_output/WEAP_output_$name/log/19_create_igv_reports.txt| parallel --bar -j 4   {}


rm -r weap.temp
mkdir time.log
mv *time.txt ./time.log

clear
cat ./about
echo "Analysis finished at "$(LANG='en_US.UTF-8'; date)
echo "Analysis finished at "$(LANG='en_US.UTF-8'; date)>>analysis_time.txt
mv analysis_time.txt ./time.log
echo -e "\n\nDone.............................."
echo -e "\n\nCheck the output files in $My_output/WEAP_output_$name/"

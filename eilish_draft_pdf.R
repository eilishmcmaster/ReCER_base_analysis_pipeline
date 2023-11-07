

# page 1
## QC 

page1 <- ((wrap_elements(grid::textGrob(report, gp = gpar(fontsize = 16)))/QC_plots) | species_map)

# page 2

page2 <-(wrap_elements(gridExtra::tableGrob(as.data.frame(final_summary),theme = ttheme_default(base_size = 6, padding = unit(c(2, 2), "mm")))) |
    ggarrange(site_map, pca_plot_pc12_site+coord_fixed(), common.legend = TRUE, legend="bottom") ) +
  plot_layout(widths = c(2,3 ))+
  plot_annotation(title = paste(species, 'site summary'))



page3 <- combined_site_pca/combined_latitude_pca+
  plot_annotation(
    title = paste(species, 'PCA'),
  )
page4 <- (((wrap_elements(gridExtra::tableGrob(as.data.frame(site_stats[,c(14,15,1,2,4:5,7,13)]),theme = ttheme_default(base_size = 6, padding = unit(c(2, 2), "mm"))))) |
            combined_stats_plot)+
  plot_layout(widths = c(2,3)))+
  plot_annotation(
    title = paste(species, 'diversity'),
    caption = paste0('Note: Samples are grouped by ', species_col_name, ' before filtering for MAF (', maf_val,') and missingness (',missingness,')')
  )

page5 <-  arranged_scatterpie_plots + plot_annotation( title = paste(species, 'LEA plots') )

page6 <-  (entropy_plot+theme(aspect.ratio = 2/3) | fst_manning) +
  plot_annotation( title = paste(species, 'LEA entropy plot and FST by distance'),
                   caption = paste0('Entropy note: The cross-entropy criterion assesses model fit for K populations by evaluating the prediction of masked genotypes,\n with a lower cross-entropy indicating a better model fit and aiding in the selection of the number of ancestral populations\nor the best model run for a fixed K value.'))

output_pdf <- paste0(species,"/outputs/plots/all_plots.pdf")

pdf(output_pdf, width = 11, height = 8.5)
plot(page1)
plot(page2)
plot(page3)
plot(page4)
plot(page5)
plot(page6)
dev.off()

pdfs_to_combine <- c(paste0(species,"/outputs/plots/all_plots.pdf"),
  paste0(species, "/outputs/plots/FST_heatmap.pdf"),
  # paste0(species,"/outputs/plots/LEA_scatterpie_map.pdf"),
  paste0(species,"/outputs/plots/LEA_barplots.pdf")  
  # paste0(species, "/outputs/plots/PLINK_kin_heatmap.pdf"),
  # paste0(species, "/outputs/plots/EUCLIDEAN_dist_heatmap.pdf")
)

qpdf::pdf_combine(input = pdfs_to_combine,
                  output = paste0(species,"/outputs/plots/",species,"_combined_outputs.pdf"))


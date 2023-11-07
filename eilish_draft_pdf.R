

# page 1
## QC 

page1 <- (wrap_elements(grid::textGrob(report))/QC_plots) | species_map

# page 2

page2 <-(wrap_elements(gridExtra::tableGrob(as.data.frame(final_summary),theme = ttheme_default(base_size = 6, padding = unit(c(2, 2), "mm")))) |
    ggarrange(site_map, pca_plot_pc12_site+coord_fixed(), common.legend = TRUE, legend="bottom") ) +
  plot_layout(widths = c(2,3 ))

# page 3

# # heatmap
# heatmap_width <- nrow(dist_heatmap)*0.1 + 7
# heatmap_height <- nrow(dist_heatmap)*0.1 + 1
# 
# filename <- paste0(species, "/outputs/plots/PLINK_kin_heatmap.pdf")
# pdf(filename, width = heatmap_width, height = heatmap_height)
# draw(hma, merge_legend = TRUE)
# dev.off()
# 
# # Page 4
# 
# filename <- paste0(species, "/outputs/plots/EUCLIDEAN_dist_heatmap.pdf")
# pdf(filename, width = heatmap_width, height = heatmap_height)
# draw(dist_heatmap_plot, merge_legend = TRUE)
# dev.off()

# Page 5
#PCA


page3 <- combined_site_pca/combined_latitude_pca
page4 <- (((wrap_elements(gridExtra::tableGrob(as.data.frame(site_stats[,c(14,15,1,2,4:5,7,13)]),theme = ttheme_default(base_size = 6, padding = unit(c(2, 2), "mm"))))) |
            combined_stats_plot)+
  plot_layout(widths = c(2,3)))+
  plot_annotation(
    title = paste(species, 'diversity'),
    # subtitle = 'These 3 plots will reveal yet-untold secrets about our beloved data-set',
    caption = paste0('Note: Samples are grouped by ', species_col_name, ' before filtering for MAF (', maf_val,') and missingness (',missingness,')')
  )

page5 <- (entropy_plot+theme(aspect.ratio = 2/3) | arranged_scatterpie_plots)+plot_layout(widths = c(1,3))

output_pdf <- paste0(species,"/outputs/plots/all_plots.pdf")

pdf(output_pdf, width = 11, height = 8.5)
# plot(page1)
# plot(page2)
# plot(page3)
plot(page4)
# plot(page5)
dev.off()



pdfs_to_combine <- c(paste0(species,"/outputs/plots/all_plots.pdf"),
  # paste0(species, "/outputs/plots/PLINK_kin_heatmap.pdf"),
  # paste0(species, "/outputs/plots/EUCLIDEAN_dist_heatmap.pdf"),
  paste0(species, "/outputs/plots/FST_heatmap.pdf"),
  paste0(species,"/outputs/plots/LEA_scatterpie_map.pdf"),
  paste0(species,"/outputs/plots/LEA_barplots.pdf")
)

qpdf::pdf_combine(input = pdfs_to_combine,
                  output = paste0(species,"/outputs/plots/combined.pdf"))
# Page 6 
# diversity 
ggsave(paste0(species,"/outputs/plots/DIVERSITY_maps.png"), plot = combined_stats_plot, width = 30, height = 25, dpi = 600, units = "cm")

# Page 7
## fst
filename <- paste0(species, "/outputs/plots/FST_heatmap.pdf")
gene_width <- nrow(mat2)*unit(4, "mm")
pdf(filename, width = (((nrow(mat2)*4)/10) +8)*0.394, height = (((nrow(mat2)*4)/10)+5)*0.394)
draw(geo + gene, ht_gap = -gene_width)
dev.off()

# Page 8
# LEA
ggsave(paste0(species,"/outputs/plots/LEA_scatterpie_map.pdf"), device="pdf",
       plot = arranged_scatterpie_plots, width = 17, height = 25, units = "cm")

# Page 9
ggsave(paste0(species,"/outputs/plots/LEA_barplots.pdf"), device="pdf",
       plot = arranged_admix_plots, width = 30, height = 40, units = "cm")




pdf("myOut.pdf")
for (i in 1:10){
  plot(...)
}
dev.off()

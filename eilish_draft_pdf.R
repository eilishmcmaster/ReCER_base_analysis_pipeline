output_pdf <- paste0(species,"/outputs/plots/all_plots.pdf")

pdf(output_pdf, width = 11, height = 8.5)
# plot(page1)
plot(page2)
# plot(page3)
dev.off()

# page 1
## QC 

page1 <- (wrap_elements(grid::textGrob(report))/QC_plots) | species_map

# page 2

page2 <-(wrap_elements(
  gridExtra::tableGrob(
    as.data.frame(final_summary),
    theme = ttheme_default(base_size = 6, padding = unit(c(1, 1), "mm")))) | ggarrange(site_map, pca_plot_pc12_site, common.legend = TRUE, position="bottom") )# + plot_layout(widths = c(1, 2)

# page 3

# heatmap
heatmap_width <- nrow(dist_heatmap)*0.1 + 7
heatmap_height <- nrow(dist_heatmap)*0.1 + 1

filename <- paste0(species, "/outputs/plots/PLINK_kin_heatmap.pdf")
pdf(filename, width = heatmap_width, height = heatmap_height)
draw(hma, merge_legend = TRUE)
dev.off()

# Page 4

filename <- paste0(species, "/outputs/plots/EUCLIDEAN_dist_heatmap.pdf")
pdf(filename, width = heatmap_width, height = heatmap_height)
draw(dist_heatmap_plot, merge_legend = TRUE)
dev.off()

# Page 5
#PCA


page3 <- combined_site_pca/combined_latitude_pca

ggsave(paste0(species,"/outputs/plots/PCA_",species_col_name,"_PC12.png"), plot = pca_plot_pc12_species, width = 20, height = 15, dpi = 600, units = "cm")
ggsave(paste0(species,"/outputs/plots/PCA_",site_col_name,"_all.png"), plot = combined_site_pca, width = 30, height = 10, dpi = 600, units = "cm")
ggsave(paste0(species,"/outputs/plots/PCA_latitude_all.png"), plot = combined_latitude_pca, width = 30, height = 10, dpi = 600, units = "cm")

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

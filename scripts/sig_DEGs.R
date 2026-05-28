library(ggplot2)
library(tidyverse)
library(patchwork)

files <- list.files("data/DEGs/",
                    pattern = "\\.csv$",
                    full.names = TRUE)

combined_df <- files %>%
  set_names() %>%
  map_dfr(~ read_csv(.x) %>%
            mutate(
              source_file = basename(.x),
              group = str_remove(basename(.x), "_DEG_analysis\\.csv$")
            ))


markers2 <- combined_df %>%
  mutate(
    regulation = case_when(
      log2FoldChange > 1 & padj < 0.05  ~ "Up",
      log2FoldChange < -1 & padj < 0.05 ~ "Down",
      TRUE ~ "NS"
    )
  )


sig <- subset(markers2, abs(log2FoldChange) > 1 & padj < 0.05)
sig <- sig[sig$regulation %in% c("Up", "Down"), ]


df_counts <- as.data.frame(table(sig$group, sig$regulation))
colnames(df_counts) <- c("group", "regulation", "n")

totals <- as.data.frame(table(sig$group))
colnames(totals) <- c("group", "total_sig")

df_summary <- merge(df_counts, totals, by = "group")
df_summary$percentage <- df_summary$n / df_summary$total_sig * 100

df_summary$regulation <- factor(df_summary$regulation, levels = c("Up", "Down"))


df_summary$group <- factor(
  df_summary$group,
  levels = rev(c(
    "DMSO_OHT_DMSO",
    "PlaB_DMSO",
    "PlaB_OHT_DMSO_OHT",
    "11j_DMSO",
    "11j_OHT_DMSO_OHT",
    "KV_DMSO",
    "KV_OHT_DMSO_OHT",
    "11j_PlaB_DMSO",
    "11j_PlaB_OHT_DMSO_OHT",
    "KV_PlaB_DMSO",
    "KV_PlaB_OHT_DMSO_OHT"
  ))
)


b <- ggplot(df_summary,
       aes(x = group,
           y = percentage,
           fill = regulation)) +
  
  geom_bar(stat = "identity", alpha = 0.85) +
  
  scale_fill_manual(values = c(
    Up = "#d55e5e",
    Down = "#4a86c5"
  )) +
  
  theme_bw(base_size = 14) +
  
  labs(x = NULL, y = NULL, fill = NULL) +
  theme(axis.text = element_blank(), axis.ticks = element_blank(), axis.line = element_blank()) + coord_flip()


df_wide <- df_summary %>%
  dplyr::select(group, regulation, n, percentage) %>%
  
  tidyr::pivot_wider(
    names_from = regulation,
    values_from = c(n, percentage),
    values_fill = 0
  ) %>%
  
  dplyr::rename(
    Up_n = n_Up,
    Down_n = n_Down,
    Up_pct = percentage_Up,
    Down_pct = percentage_Down
  )


df_wide <- df_wide %>%
  dplyr::mutate(
    Down_n = -Down_n
  )


df_wide$group <- factor(
  df_wide$group,
  levels = rev(c(
    "DMSO_OHT_DMSO",
    "PlaB_DMSO",
    "PlaB_OHT_DMSO_OHT",
    "11j_DMSO",
    "11j_OHT_DMSO_OHT",
    "KV_DMSO",
    "KV_OHT_DMSO_OHT",
    "11j_PlaB_DMSO",
    "11j_PlaB_OHT_DMSO_OHT",
    "KV_PlaB_DMSO",
    "KV_PlaB_OHT_DMSO_OHT"
  ))
)


a <- ggplot(df_wide, aes(x = group)) +
  
  geom_hline(yintercept = 0, color = "black", linewidth = 0.6) +
  
  geom_segment(aes(xend = group, y = 0, yend = Up_n),
               color = "#d55e5e", linewidth = 0.6) +
  
  geom_segment(aes(xend = group, y = 0, yend = Down_n),
               color = "#4a86c5", linewidth = 0.6) +
  
  geom_point(aes(y = Up_n), color = "#d55e5e", size = 4) +
  geom_point(aes(y = Down_n), color = "#4a86c5", size = 4) +
  
  geom_text(aes(y = Up_n,
                label = paste0(round(Up_pct, 1), "%")),
            color = "#d55e5e",
            vjust = -1.5,
            size = 3) +
  
  geom_text(aes(y = Down_n,
                label = paste0(round(Down_pct, 1), "%")),
            color = "#4a86c5",
            vjust = 2,
            size = 3) +
  
  coord_flip() +
  
  theme_bw(base_size = 14) +
  
  labs(
    y = "Number of significant differential expressed genes",
    x = NULL
  )

pdf("figures/sig_DEGs.pdf", width = 14)
a | b
dev.off()


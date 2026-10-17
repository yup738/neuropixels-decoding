install.packages(c("readr", "dplyr", "ggplot2"))

library(readr)
library(dplyr)
library(ggplot2)

# Remember to set working directory to main folder
res <- read_csv("results/decoding_by_n.csv")

# Summary table
summ <- res |>
  group_by(n_units) |>
  summarise(
    mean = mean(accuracy),
    sd = sd(accuracy),
    n_subsets = n(),
    min = min(accuracy),
    max = max(accuracy),
    .groups = "drop"
  )
print(summ)
write_csv(summ, "results/decoding_by_n_summary.csv")

p <- ggplot(res, aes(x = n_units, y = accuracy)) + 
  geom_hline(yintercept = 1/6, linetype = "dashed", colour = "grey50") +
  annotate("text", x = 1, y = 1/6 - 0.03, label = "chance (1/6)",
           hjust = 0, size = 3.3, colour = "grey40") + 
  # every individual random subset
  geom_point(alpha = 0.25, size = 1.2,
             position = position_jitter(width = 0.02, height = 0)) + 
  # mean across subsets, with SD
  geom_line(data = summ, aes(y = mean), linewidth = 0.7) +
  geom_errorbar(data = summ, aes(y = mean, ymin = mean - sd, ymax = mean + sd),
                width = 0.05, na.rm = TRUE) + 
  geom_point(data = summ, aes(y = mean), size = 2.4) + 
  scale_x_log10(breaks = c(1, 2, 5, 10, 20, 50, 100, 200, 337)) +
  scale_y_continuous(limits = c(0, 0.8), breaks = seq(0, 0.8, 0.2)) +
  labs(
    x = "Number of units (random subsets)",
    y = "Decoding accuracy (5-fold CV)",
    caption = paste0("Faint points: individual random subsets (20 per size; 1 at n=337).\n",
                     "Line and bars: mean ± SD across subsets. One mouse, one session.")
  ) +
  theme_classic(base_size = 12) +
  theme(plot.caption = element_text(hjust = 0, size = 8.5, colour = "grey30"))

ggsave("results/decoding_vs_population_size.png", p, width = 6, height = 4, dpi = 300)
p

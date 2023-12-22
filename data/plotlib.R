Sys.setenv("_R_CHECK_LENGTH_1_CONDITION_" = "true")
options(warnPartialMatchDollar = TRUE,
        warnPartialMatchArgs = TRUE)
Sys.setenv("VROOM_CONNECTION_SIZE" = 131072 * 2)

library(tibble)
library(tidyr)
library(purrr) # for map_lgl
library(readr)
library(dplyr, warn.conflicts = FALSE)
library(stringr)
library(ggplot2)
## library(plotly)
## library(htmlwidgets)
library(scriptName)
library(argparse)
library(tikzDevice)
library(gghighlight)

tidy_dir <- Sys.getenv("TIDY_DIR", unset=".tidy")

parser <- ArgumentParser(description='Plot tidy evaluation data.')
parser$add_argument("-d", "--data")
parser$add_argument("-i", "--tidy-path")
parser$add_argument("-p", "--plot-path")
args <- parser$parse_args()

if (exists("data_name")) {
  print("Info: Using $data_name from R environment.")
} else if (!is.null(args$data)) {
  data_name <- args$data
} else if (is.null(args$tidy_path)) {
  data_name <- "scratch"
}

if (exists("data_name")) {
  tidy_path <- file.path(tidy_dir, paste0(data_name, ".tsv.gz"))
} else {
  tidy_path <- args$tidy_path
}

if (!is.null(args$plot_path)) {
  plot_path <- args$plot_path
} else {
  if (is.null(current_cli_filename())) {
    script_name <- "interactive"
  } else {
    script <- basename(current_cli_filename())
    script_name <<- sub("^plot-", "", script)
  }
  plot_path <- file.path("plots", data_name, script_name)
}

plotlib_eval_id <- 1

eval_path <- function(plot_name, plotlib_eval_id, suffix) {
  file.path(plot_path,
            paste0(
              str_pad(plotlib_eval_id, 4, pad = "0"),
              "-",
              str_replace_all(
                str_replace_all(
                  URLencode(plot_name, reserved = TRUE),
                  "%20", "_"),
                "%", ":"),
              suffix))
}

TEXT_COL_WIDTH_INCH <- 3.327

eval_save_tikz <- function(plot_name) {
  tikz(file = eval_path(plot_name, 0, ".tex"), width = TEXT_COL_WIDTH_INCH, height = 0.68*TEXT_COL_WIDTH_INCH)
}

eval_save <- function(plot_name, eval_id = plotlib_eval_id,
                      title=plot_name, subtitle=paste0("eval-id = ", eval_id),
                      width_cm=16*3, height_cm=9*3) {
  lp <- last_plot() + labs(title = title, subtitle = subtitle)
  ep <- eval_path(plot_name, eval_id, ".pdf")
  ggsave(ep,
         plot = lp,
         width = width_cm, height = height_cm,
         units = "cm")
  plotlib_eval_id <<- plotlib_eval_id + 1
}

geomean <- function(y) exp(mean(log(y)))

ALL_DATA <- read_tsv(
  tidy_path,
  col_types = cols(
    perf_l1_icache_load_misses = col_double(),
    perf_l1_dcache_load_misses = col_double(),
    bpftool_loadall_exitcode = col_integer()
  )
)

cols = c(bpftool_jited_insncnt_lfence = NA_real_,
         bpftool_jited_insncnt_total = NA_real_,
         bpftool_prog_show_run_time_ns = NA_real_,
         perf_task_clock_msec = NA_real_,
         perf_duration_time_ns = NA_real_,
         bpftool_run_exitcode = NA_integer_,
         bpftool_prog = NA,
         verification_error = NA,
         verification_error_msg = NA,
         bpftool_loadall_exitcode = NA_integer_,
         bpftool_loadall_error_reason_msg = NA,
         OSE_CPUFREQ = NA,
         OSE_SYSCTL = NA,
         OSE_BPF_OBJ = NA,
         OSE_CAPSH_ARGS = NA)

DATA <- ALL_DATA %>%
  tibble::add_column(!!!cols[!names(cols) %in% names(.)]) %>%
  mutate(
    ## CPU = factor(case_when(
    ##   boot_T == "easy16" ~ "AMD 3950X",
    ##   boot_T == "nuc" ~ "Intel i5-6260U",
    ##   ), levels = c("AMD 3950X", "Intel i5-6260U")),
    bpftool_prog_show_run_time_s = bpftool_prog_show_run_time_ns / (1000*1000*1000),
    perf_task_clock_s = perf_task_clock_msec / 1000,
    perf_duration_time_s = perf_duration_time_ns  / (1000*1000*1000),
    Caches = factor(case_when(
      burst_pos == 0 ~ "Cold Caches",
      burst_pos == max(burst_pos) ~ "Hot Caches",
      TRUE ~ "Warm Caches",
      ), levels = c("Cold Caches", "Hot Caches")),
    User = factor(case_when(
      OSE_CAPSH_ARGS == "--drop=" ~ "Privileged",
      OSE_CAPSH_ARGS == "--drop=cap_sys_admin --drop=cap_perfmon" ~ "Unprivileged",
      ), levels = c("Privileged", "Unprivileged")),
    `BPF Loadable` = bpftool_loadall_exitcode == 0,
    OSE_SYSCTL = case_when(
      is.na(OSE_SYSCTL) ~ "Default (bpf_*=0)",
      OSE_SYSCTL == "net.core.bpf_jit_harden=0" ~ "Default (bpf_*=0)",
      TRUE ~ OSE_SYSCTL
    ),
    Project = case_when(
      str_detect(OSE_BPF_OBJ, "^lbe_") ~ "libbpf/examples",
      str_detect(OSE_BPF_OBJ, "^vbi-") ~ "vbpf-imports",
      str_detect(OSE_BPF_OBJ, "^vbi-") ~ "vbpf-imports",
      TRUE ~ str_extract(OSE_BPF_OBJ, "^[a-z-]+")
    ),
    `BPF Program Type` = factor(
      case_when(
        OSE_BPF_OBJ == "linux-selftests_test_l4lb.bpf.o" ~ "Real",
        OSE_BPF_OBJ == "linux-selftests_test_l4lb_noinline.bpf.o" ~ "Real",
        OSE_BPF_OBJ == "linux-selftests_xdp_synproxy_kern.bpf.o" ~ "Real",
        OSE_BPF_OBJ == "linux-selftests_xdp_vlan.bpf.o" ~ "Real",
        Project == "linux-selftests" ~ "Test / Example",
        Project == "linux" ~ "Test", # legacy linux-selftests
        Project == "linux-samples" ~ "Test / Example",
        Project == "cilium" ~ "Real",
        Project == "vbpf" ~ "Test / Example",
        Project == "libbpf/examples" ~ "Test / Example",
        Project == "llb" ~ "Real",
        TRUE ~ "Unspecified"
      ),
      levels = c("Real", "Test / Example", "Unspecified")
    ),
    `lfence / Total Instructions [%]` = 100 * bpftool_jited_insncnt_lfence / bpftool_jited_insncnt_total,
    verification_error = verification_error_msg %>%
      ## CORE:
      str_replace_all(" enum[0-9]+ .+ = [0-9]+", " *") %>%
      str_replace_all(" enum .+", " *") %>%
      str_replace_all(" struct .+", " *") %>%
      ## etc
      str_replace_all("func .+#", "func *#") %>%
      str_replace_all("<.+>", "<*>") %>%
      str_replace_all("'.+'", "'*'") %>%
      str_replace_all("0x[0-9a-f]+", "*") %>%
      str_replace_all("[0-9:]+", "*") %>%
      ## Priv:
      str_replace_all(" !root", " $USER"),
    bpftool_loadall_error_reason = bpftool_loadall_error_reason_msg %>%
      str_replace_all("extern '.+'.+ -[0-9]+$", "extern *") %>%
      str_replace_all(" [0-9:]+", " *") %>%
      str_replace_all("'.+.bpf.o'", "'*.bpf.o'") %>%
      str_replace_all(" '.+'", " '*'"),
    `BPF Load` = case_when(
      is.na(verification_error) ~ "Success",
      str_detect(verification_error, "variable stack access prohibited for ") ~ "Error: Variable Stack Access",
      str_detect(verification_error, "tried to add from different maps, paths or scalars, pointer arithmetic with it prohibited for") ~ "Error: Variable Stack Access",
      str_detect(verification_error, "R. has unknown scalar with mixed signed bounds, pointer arithmetic with it prohibited for") ~ "Error: Variable Stack Access",
      str_detect(verification_error, "R. has pointer with unsupported alu operation, pointer arithmetic with it prohibited for") ~ "Error: Types",
      str_detect(verification_error, "R. type=.+ expected=.*") ~ "Error: Types",
      str_detect(verification_error, "invalid zero-sized read") ~ "Error: Types",
      str_detect(verification_error, "R. invalid mem access '.+'") ~ "Error: Breakout",
      str_detect(verification_error, "math between map_value pointer and register with unbounded min value is not allowed") ~ "Error: Breakout",
      str_detect(verification_error, "R. pointer arithmetic of map value goes out of range, prohibited for .+") ~ "Error: Breakout",
      str_detect(verification_error, "The sequence of .+ jumps is too complex.") ~ "Error: Too Complex",
      bpftool_loadall_exitcode != "0" ~ paste("Error:", "Other")
    )
  )

COL_WIDTH_CM=8.5
COL_HEIGHT_CM=6

THESIS_WIDTH_CM=14.5
THESIS_HEIGHT_CM=THESIS_WIDTH_CM*0.9
THESIS_FULL_HEIGHT_CM=20

PRES_W=21
PRES_H=PRES_W*(8/16)

## https://personal.sron.nl/~pault/#qualitativescheme
color_bblue <- "#4477aa"
color_bcyan <- "#66ccee"
color_bgreen <- "#228833"
color_bpurple <- "#228833"
color_byellow <- "#ccbb44"
color_bpurple <- "#aa3377"

color_vcyan <- "#33bbee"
color_vteal <- "#009988"
color_vblue <- "#0077bb"

color_hcyellow <- "#ddaa33"
color_hcred <- "#bb5566"
color_hcblue <- "#004488"
color_hcblack <- "#000000"

color_olive <- "#999933"

color_mindigo <- "#332288"

colors_hc4 <- c(color_hcblack, color_hcblue, color_hcred, color_hcyellow)
colors_hc3 <- c(color_hcblue, color_hcred, color_hcyellow)
colors_hc2 <- c(color_hcyellow, color_hcblue)

color_bpf <- color_vblue

color_fau_yellow <- "#d9c689"
color_fau_darkyellow <- "#c99313"
color_fau_lightyellow <- "#f3eedf"
color_fau_darkblue <- "#003865"
color_fau_blue <- "#90a7c6"
color_fau_lightblue <- "#dde5f0"

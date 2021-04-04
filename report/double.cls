\ProvidesClass{double}
\NeedsTeXFormat{LaTeX2e}
\LoadClass[10pt]{article}
\usepackage[top=1.5cm, bottom=2cm, left=1.5cm, right=1.5cm]{geometry}
\usepackage[utf8]{inputenc}
\usepackage[bitstream-charter]{mathdesign}
\usepackage[T1]{fontenc}
\usepackage{graphicx}
\usepackage{amsmath}
\usepackage{float}
\usepackage{tikz}
\usepackage{tikzscale}
\usepackage{siunitx}
\usepackage{listings}
\usepackage{multicol}
\usepackage{titlesec}
\usepackage[colorlinks=true, linkcolor=blue, citecolor=blue]{hyperref}
\usepackage[style=science,backend=biber]{biblatex}
\addbibresource{output.bib}

%% tweaks to the defaults
% tightlist 
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
% title style changes
\titleformat{\section}{\normalfont\large\centering}{\arabic{section}.}{0.5em}{\MakeUppercase}[]
\titleformat{\subsection}{\large\itshape}{\textup{\Roman{subsection}}}{0.5em}{}[]
% enumerate style changes
\renewcommand{\labelenumi}{\arabic{enumi}) }
\setlength\columnsep{2em}
% cite and url fontstyle changes
\renewcommand{\UrlFont}{\normalfont}
\renewrobustcmd*{\mkbibemph}{}
\protected\long\def\blx@imc@mkbibemph#1{#1}


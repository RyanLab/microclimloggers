### Summary

-   What does this package do? (explain in 50 words or less):
Microclimate loggers (e.g. iButton, iButton Hygrochron, HOBO pendant loggers) are commonly used in the environmental and biological sciences to record . They usually require proprietary hardware and software interfaces to download data and transcribe it into CSV-like or spreadsheet-like formats. These transcribed data formats differ between models and/or manufacturers, making synthesis of data from   An R package to process various microclimate logger data formats. Functions are provided to parse and reshape microclimate logger data (e.g. iButton, iButton Hygrochron, HOBO pendant loggers) that 


-   Paste the full DESCRIPTION file inside a code block below:

```

```

-   URL for the package (the development repository, not a stylized html page):

-   Who is the target audience?  

-   Are there other R packages that accomplish the same thing? If so, what is different about yours?  
 There are a handful of solutions for individual logger makes or models e.g. https://github.com/search?l=R&q=ibutton&type=Repositories&utf8=%E2%9C%93 , the most mature is possibly https://github.com/aammd/ibuttonr, but to our best knowledge there are no packages on CRAN, and packages supporting loggers from different manufacturers

### Requirements

Confirm each of the following by checking the box.  This package:

- [x] does not violate the Terms of Service of any service it interacts with. 
- [x] has a CRAN and OSI accepted license.
- [x] contains a README with instructions for installing the development version. 
- [ ] includes documentation with examples for all functions.
- [ ] contains a vignette with examples of its essential functions and uses.
- [ ] has a test suite.
- [x] has continuous integration with Travis CI and/or another service.

#### Publication options

- [x] Do you intend for this package to go on CRAN?  
- [ ] Do you wish to automatically submit to the [Journal of Open Source Software](http://joss.theoj.org/)? If so:
    - [ ] The package contains a [`paper.md`](http://joss.theoj.org/about#paper_structure) with a high-level description in the package root or in `inst/`.
    - [ ] The package is deposited in a long-term repository with the DOI: 
    - (*Do not submit your package separately to JOSS*)

### Detail

- [x] Does `R CMD check` (or `devtools::check()`) succeed?  Paste and describe any errors or warnings:

- [ ] Does the package conform to [rOpenSci packaging guidelines](https://github.com/ropensci/packaging_guide)? Please describe any exceptions:

- If this is a resubmission following rejection, please explain the change in circumstances:

- If possible, please provide recommendations of reviewers - those with experience with similar packages and/or likely users of your package - and their GitHub user names:


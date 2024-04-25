# Changelog

## [Unreleased]

**Added**
- export to .txt file 

**Changed**
- peat depth unit changed from m to cm
    - updated the columns of the input data 
        - `torvdybde_cm` instead of `Dybde`
        - `peat_depth_cm` instead of `Dybde`
    - updated the calculations to still calc. volume in m3
- allow for input data with different coord. systems.
    - all coordinates are transformed to `ETRS89 UTM zone 33N` (EPSG:25833).
    - update default to `ETRS89 UTM zone 33N` (EPSG:25833) 
- new order UI-elements in the sidebar
- updated documentation and inline comments

**Removed**
- empty mapframe in the output interpolation map is deleted.

## Version 1.0.0 (2023-16-01)

*Official release*

**Added**
- visulization of the power parameter

**Changed**
- better error handling
- improved peat depth interpolation 

## Version 0.1.0-alpha (2022-10-25)

*Pre-release*
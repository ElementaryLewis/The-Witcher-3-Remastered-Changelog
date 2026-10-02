# The Witcher 3 Remastered Changelog
Changelog of The Witcher 3: Wild Hunt - Remastered.

# Description
GitHub repository to survey every The Witcher 3 game update from Next-Gen 4.04 to Remastered 5.00 and forward.
This is meant as a resource for modders, helping them to know which files were changed and what the changes are, so they can update their mods for the Remastered version if needed.

**All files are encoded in UFT-8! They were previously UFT-16 LE BOM in Next-Gen version.**

For the purpose of creating a comparison commit, most but not all "false positive" changes were removed.

For instance:

*Next-Gen*
```
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
<?xml version="1.0" encoding="UTF-16"?>
```
*Remastered*
```
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
<?xml version="1.0" encoding="UTF-8"?>
```

## List of changelog commits

### SCRIPTS 
| PREVIOUS VERSION | NEW VERSION | DATE RELEASE |
| ---------------- |:-----------:| ------------:|
| [4.04b](https://github.com/ElementaryLewis/Witcher-3-Next-Gen-Changelog/commit/e8a76234533a6a3f5928f55b0e6ea0e32b03539c "Scripts 4.04 vs 4.04a_REDkit") | [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/e026f253c8790ebcfe545188eb0ae77978dc1178 "Scripts 4.04b vs 5.00b") | 2026/09/29 |
| [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/e026f253c8790ebcfe545188eb0ae77978dc1178 "Scripts 4.04b vs 5.00b") | [5.00c](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/214904d1349a26ee174a2c2f7721c5d73ba6357c "Scripts 5.00b vs 5.00c") | 2026/10/01 |
| [5.00c](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/214904d1349a26ee174a2c2f7721c5d73ba6357c "Scripts 5.00b vs 5.00c") | [5.XX]( "Scripts 5.00c vs 5.XX") | 2026/XX/XX |


### XML
| PREVIOUS VERSION | NEW VERSION | DATE RELEASE |
| ---------------- |:-----------:| ------------:|
| [4.04b](https://github.com/ElementaryLewis/Witcher-3-Next-Gen-Changelog/commit/15e2b662b3a9145e7d24e72c4e8ab37aac0f2db3 "XML 4.02 vs 4.03") | [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/bbdc09e016e5c0add4321a1140e19deff0e402eb "Scripts 4.04b vs 5.00b") | 2026/09/29 |
| [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/bbdc09e016e5c0add4321a1140e19deff0e402eb "XML 4.04b vs 5.00") | [5.XX]( "XML 5.00b vs 5.XX") | 2026/XX/XX |

### CSV
| PREVIOUS VERSION | NEW VERSION | DATE RELEASE |
| ---------------- |:-----------:| ------------:|
| [4.04b](https://github.com/ElementaryLewis/Witcher-3-Next-Gen-Changelog/commit/d0e37d82188654cd5e4abb2f4ff70edfcc097688 "CSV 4.04 vs 4.04a_REDkit") | [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/7907fdbb70f3fd2609b787eba84478ab498caefb "Scripts 4.04b vs 5.00b") | 2026/09/29 |
| [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/7907fdbb70f3fd2609b787eba84478ab498caefb "CSV 4.04b vs 5.00b") | [5.XX]( "CSV 5.00b vs 5.XX") | 2026/XX/XX |

### W3STRINGS
| PREVIOUS VERSION | NEW VERSION | DATE RELEASE |
| ---------------- |:-----------:| ------------:|
| [4.04b](https://github.com/ElementaryLewis/Witcher-3-Next-Gen-Changelog/commit/aded0c0885c208f68b068defe18c4638db187e98 "W3Strings 4.03 vs 4.04") | [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/5bc023261fb9f51593c698623886b98664cae0d2 "Scripts 4.04b vs 5.00b") | 2026/09/29 |
| [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/commit/5bc023261fb9f51593c698623886b98664cae0d2 "W3Strings 4.04b vs 5.00b") | [5.XX]( "W3Strings 5.00b vs 5.XX") | 2026/XX/XX |

### BUNDLED NON-TEXT
| PREVIOUS VERSION | NEW VERSION | DATE RELEASE |
| ---------------- |:-----------:| ------------:|
| [4.04b](https://raw.githubusercontent.com/ElementaryLewis/Witcher-3-Next-Gen-Changelog/refs/heads/main/CR2W_summary/CR2W_changed-list.txt "Bundled 1.32 vs 4.00") | [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/blob/main/Bundled%20Non%20Text/Bundled%20Non%20Text%204.04b%20vs%205.00b.txt "Scripts 4.04b vs 5.00b") | 2026/09/29 |
| [5.00b](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/blob/main/Bundled%20Non%20Text/Bundled%20Non%20Text%204.04b%20vs%205.00b.txt "Bundled 4.04b vs 5.00b") | [5.00c](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/blob/main/Bundled%20Non%20Text/Bundled%20Non%20Text%205.00b%20vs%205.00c.txt "Bundled 5.00b vs 5.00c") | 2026/10/01 |
| [5.00c](https://github.com/ElementaryLewis/The-Witcher-3-Remastered-Changelog/blob/main/Bundled%20Non%20Text/Bundled%20Non%20Text%205.00b%20vs%205.00c.txt "Bundled 5.00c vs 5.XX") | [5.XX]("Bundled 5.00b vs 5.XX") | 2026/XX/XX |


#### Our Discord Servers:
[![Wolven Workshop](https://i.postimg.cc/fTfh832X/LWEWdb-N-Imgur.png)](https://discord.gg/xPBgHs42Cb)[![Brothers In Arms](https://i.postimg.cc/TYJXty7g/h-C5n-TJY-Imgur.png)](https://discord.gg/nb9N4vjKGR)

###### This repository is not affiliated with CD Projekt RED. All files belong to the CD Projekt company.
#需改為從txpull拿
puts 'BookMaker seeds importing...'
BookMaker.create([
                    { name: 'Centrebet', tx_id: 2 },
                    { name: 'Admiral', tx_id: 4 },
                    { name: 'Expekt', tx_id: 5 },
                    { name: 'Unibet', tx_id: 6 },
                    { name: 'Betshop', tx_id: 9 },
                    { name: 'Sportingbet', tx_id: 13 },
                    { name: 'Intertops', tx_id: 15 },
                    { name: 'Ladbrokes', tx_id: 17 },
                    { name: 'Oddset', tx_id: 20 },
                    { name: 'VCBet', tx_id: 22 },
                    { name: 'Interwetten', tx_id: 26 },
                    { name: 'Easybets', tx_id: 27 },
                    { name: 'bwin', tx_id: 30 },
                    { name: 'Stan James', tx_id: 34 },
                    { name: 'Fonbet', tx_id: 37 },
                    { name: 'Veikkaus', tx_id: 39 },
                    { name: 'Norway', tx_id: 41 },
                    { name: 'William Hill', tx_id: 42 },
                    { name: 'Danske Spil', tx_id: 43 },
                    { name: 'Sweden', tx_id: 44 },
                    { name: 'bet-at-home', tx_id: 49 },
                    { name: 'gamebookers', tx_id: 52 },
                    { name: 'TheGreek.com', tx_id: 53 },
                    { name: 'Chance', tx_id: 58 },
                    { name: 'GWbet', tx_id: 59 },
                    { name: 'SportsTAB', tx_id: 65 },
                    { name: 'CaribSports', tx_id: 67 },
                    { name: 'Victorytip', tx_id: 68 },
                    { name: 'Nike', tx_id: 70 },
                    { name: 'Cash Point', tx_id: 75 },
                    { name: 'Stanleybet', tx_id: 76 },
                    { name: 'PinnacleSports', tx_id: 83 },
                    { name: 'Paddy Power', tx_id: 84 },
                    { name: 'STS', tx_id: 92 },
                    { name: 'BETDAQ', tx_id: 109 },
                    { name: 'Betfair', tx_id: 110 },
                    { name: 'SNAI', tx_id: 117 },
                    { name: 'Nordicbet', tx_id: 118 },
                    { name: 'BET 1128', tx_id: 119 },
                    { name: 'Bet 365', tx_id: 126 },
                    { name: 'GoldBet', tx_id: 128 },
                    { name: 'Iceland', tx_id: 155 },
                    { name: 'Boylesports', tx_id: 158 },
                    { name: 'Sazka', tx_id: 159 },
                    { name: 'Tote', tx_id: 163 },
                    { name: 'SportBet', tx_id: 197 },
                    { name: 'sportsbook.com', tx_id: 212 },
                    { name: 'skybet', tx_id: 221 },
                    { name: 'Macau Slot', tx_id: 229 },
                    { name: '5 Dimes', tx_id: 234 },
                    { name: 'Tipsport-Sk', tx_id: 235 },
                    { name: 'BoDog', tx_id: 236 },
                    { name: 'BETCRIS', tx_id: 238 },
                    { name: 'Coral', tx_id: 244 },
                    { name: 'HK Jockey Club', tx_id: 245 },
                    { name: 'Synot TIP', tx_id: 270 },
                    { name: 'Toto', tx_id: 271 },
                    { name: '10BET', tx_id: 274 },
                    { name: 'StarPrice', tx_id: 275 },
                    { name: 'Singbet', tx_id: 282 },
                    { name: 'IBCBET', tx_id: 285 },
                    { name: 'Victoriatip', tx_id: 287 },
                    { name: 'Betfred', tx_id: 291 },
                    { name: 'Hititbet', tx_id: 313 },
                    { name: 'Matchbook', tx_id: 314 },
                    { name: 'sbobet.com', tx_id: 327 },
                    { name: 'Betsafe', tx_id: 332 },
                    { name: 'Milenium', tx_id: 333 },
                    { name: 'TotoSi', tx_id: 334 },
                    { name: 'myBet.com', tx_id: 336 },
                    { name: 'Betway', tx_id: 340 },
                    { name: 'Betsson Sportsbook', tx_id: 342 },
                    { name: 'Betstar', tx_id: 345 },
                    { name: 'Doxxbet', tx_id: 355 },
                    { name: 'MeridianBet', tx_id: 357 },
                    { name: 'DiamondSportsBook', tx_id: 359 },
                    { name: 'BetGun.com', tx_id: 360 },
                    { name: 'Tipico', tx_id: 363 },
                    { name: '188bet', tx_id: 365 },
                    { name: 'bookmaker.eu', tx_id: 378 },
                    { name: 'PartyBets', tx_id: 380 },
                    { name: 'Mansion88.com', tx_id: 385 },
                    { name: 'Eurobet.it', tx_id: 388 },
                    { name: 'BetClick', tx_id: 395 },
                    { name: 'Bet3000', tx_id: 399 },
                    { name: 'BetUS', tx_id: 401 },
                    { name: 'Singapore Pools', tx_id: 402 },
                    { name: 'intralot', tx_id: 403 },
                    { name: 'Efbet', tx_id: 406 },
                    { name: 'better.it', tx_id: 413 },
                    { name: 'Miseojeu', tx_id: 420 },
                    { name: 'gioco digitale', tx_id: 421 },
                    { name: 'e-stave', tx_id: 424 },
                    { name: 'LUXBET.com', tx_id: 426 },
                    { name: 'LEON', tx_id: 431 },
                    { name: '12bet.com', tx_id: 434 },
                    { name: 'bwin.it', tx_id: 449 },
                    { name: 'Pamestihima', tx_id: 451 },
                    { name: 'iddaa', tx_id: 452 },
                    { name: 'Startip', tx_id: 453 },
                    { name: 'Titanbet', tx_id: 462 },
                    { name: 'BetClic.it', tx_id: 466 },
                    { name: 'Unibet.it', tx_id: 468 },
                    { name: 'Scommettendo', tx_id: 479 },
                    { name: 'Bookie Bob', tx_id: 483 },
                    { name: 'Hrvatska Lutrija', tx_id: 487 },
                    { name: 'SuperSport', tx_id: 488 },
                    { name: 'iFortuna.eu', tx_id: 489 },
                    { name: 'Tattsbet', tx_id: 491 },
                    { name: 'Novibet', tx_id: 492 },
                    { name: 'Parionsweb', tx_id: 493 },
                    { name: 'betclick.fr', tx_id: 495 },
                    { name: 'Offsidebet', tx_id: 500 },
                    { name: 'BetAdria', tx_id: 501 },
                    { name: 'youwin', tx_id: 502 },
                    { name: 'BetOnline', tx_id: 504 },
                    { name: 'youwager.com', tx_id: 506 },
                    { name: 'iFortuna.sk', tx_id: 527 },
                    { name: 'Betfair AUS', tx_id: 528 },
                    { name: 'sportsbet.com.au', tx_id: 529 },
                    { name: 'Dafabet', tx_id: 532 },
                    { name: 'Flemington Sportsbet', tx_id: 535 },
                    { name: 'Goalbet', tx_id: 538 },
                    { name: 'Marathonbet', tx_id: 539 },
                    { name: 'betcity', tx_id: 540 },
                    { name: 'parimatch', tx_id: 541 },
                    { name: 'iziplay', tx_id: 548 },
                    { name: 'comeon!', tx_id: 550 },
                    { name: 'Betsonic', tx_id: 551 },
                    { name: 'isibet', tx_id: 552 },
                    { name: 'Millenniumbet', tx_id: 558 },
                    { name: 'Paddypower.it', tx_id: 559 },
                    { name: '138sungame', tx_id: 560 },
                    { name: 'Balkanbet', tx_id: 562 },
                    { name: 'tomwaterhouse', tx_id: 563 },
                    { name: 'Sporttery', tx_id: 564 },
                    { name: 'Olimpbet', tx_id: 565 },
                    { name: 'Bovada', tx_id: 567 },
                    { name: 'williamhill.it', tx_id: 568 },
                    { name: 'Cirsa', tx_id: 570 },
                    { name: 'betISN', tx_id: 571 },
                    { name: 'Caliente', tx_id: 573 },
                    { name: 'TonyBet', tx_id: 574 },
                    { name: 'smarkets', tx_id: 575 },
                    { name: 'Betflag', tx_id: 576 },
                    { name: 'Sisal Matchpoint', tx_id: 577 },
                    { name: 'noxwin', tx_id: 579 },
                    { name: 'fun88', tx_id: 580 },
                    { name: 'bodog88', tx_id: 581 },
                    { name: 'RB88', tx_id: 582 },
                    { name: 'williamhill.es', tx_id: 583 },
                    { name: 'interwetten.es', tx_id: 584 },
                    { name: 'bwin.es', tx_id: 585 },
                    { name: 'ApolloBET', tx_id: 589 },
                    { name: 'Setantabet', tx_id: 590 },
                    { name: 'PAF.es', tx_id: 592 },
                    { name: 'winner', tx_id: 594 },
                    { name: '138', tx_id: 595 },
                    { name: 'bet-at-home.it', tx_id: 598 },
                    { name: 'Tipico.it', tx_id: 600 },
                    { name: 'sjbet', tx_id: 601 },
                    { name: '888sport', tx_id: 604 },
                    { name: 'Bluebet.it', tx_id: 605 },
                    { name: 'Gamenet.it', tx_id: 607 },
                    { name: 'merkur-win.it', tx_id: 608 },
                    { name: 'SportYes.it', tx_id: 609 },
                    { name: 'agile.it', tx_id: 610 },
                    { name: 'betitaly.it', tx_id: 611 },
                    { name: 'domusbet.it', tx_id: 612 },
                    { name: 'Betfair SB', tx_id: 613 },
                    { name: 'stoiximan', tx_id: 615 },
                    { name: 'leaderbet', tx_id: 616 },
                    { name: 'Championsbet', tx_id: 618 },
                    { name: 'GameLux.it', tx_id: 621 },
                    { name: 'Rivalo.com', tx_id: 622 },
                    { name: 'PinnBet', tx_id: 624 },
                    { name: 'Betaland', tx_id: 625 },
                    { name: 'PlanetWin365', tx_id: 627 },
                    { name: 'MozzartBet', tx_id: 628 },
                    { name: 'SuperLenny', tx_id: 630 },
                    { name: 'NetBet', tx_id: 631 },
                    { name: 'Ladbrokes.com.au', tx_id: 632 },
                    { name: 'Spreadex', tx_id: 634 },
                    { name: 'Guts', tx_id: 635 },
                    { name: 'Bookmaker.com.au', tx_id: 636 },
                    { name: 'Fast Lane Betting', tx_id: 639 },
                    { name: 'BetRebels', tx_id: 640 },
                    { name: 'Betbright', tx_id: 641 },
                    { name: 'GR88', tx_id: 642 },
                    { name: 'GTbets', tx_id: 644 },
                    { name: 'Gazzabet.it', tx_id: 645 },
                    { name: 'NetBet.it', tx_id: 646 },
                    { name: 'FavBet', tx_id: 648 },
                    { name: '1xbet', tx_id: 649 },
                    { name: 'Statusbet', tx_id: 652 },
                    { name: 'Bet8', tx_id: 653 },
                    { name: 'Vernons', tx_id: 654 },
                    { name: 'Tempobet', tx_id: 655 },
                    { name: 'Aycons.it', tx_id: 656 },
                    { name: '2WinBet', tx_id: 657 },
                    { name: 'Bet9ja', tx_id: 658 },
                    { name: 'Favourit', tx_id: 659 },
                    { name: 'naija4win', tx_id: 660 },
                    { name: 'CrownBet', tx_id: 661 },
                    { name: 'Merrybet', tx_id: 662 },
                    { name: 'NairaBet.com', tx_id: 663 },
                    { name: '1960bet', tx_id: 664 },
                    { name: 'GiochiTelematici', tx_id: 665 },
                    { name: 'Senibet', tx_id: 666 },
                    { name: 'Tuttur.com', tx_id: 667 },
                    { name: 'Pokerstars', tx_id: 669 },
                    { name: 'WilliamHill.com.au', tx_id: 670 },
                    { name: 'PKR', tx_id: 671 },
                    { name: 'MaxBet', tx_id: 672 },
                    { name: 'ScommesseItalia', tx_id: 673 },
                    { name: 'Bet25', tx_id: 676 },
                    { name: 'SureBet247', tx_id: 680 },
                    { name: 'Luckia', tx_id: 684 },
                    { name: 'BetSport7', tx_id: 685 },
                    { name: 'Mobilbet', tx_id: 689 }
                  ])
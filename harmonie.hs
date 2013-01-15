import Data.List

-- Musical data

data Alteration = Bemol | Naturel | Diese deriving Eq

data Note = Note {getBlanche :: Int, getAlt :: Alteration}

showNoteId 0 = "Do"
showNoteId 2 = "Re"
showNoteId 4 = "Mi"
showNoteId 5 = "Fa"
showNoteId 7 = "Sol"
showNoteId 9 = "La"
showNoteId 11 = "Si"
showAlt Bemol   = "b"
showAlt Naturel = ""
showAlt Diese   = "#"

instance Show Note where
    show (Note n a) = showNoteId n ++ showAlt a

readNoteId "Do"  = 0
readNoteId "Re"  = 2
readNoteId "Mi"  = 4
readNoteId "Fa"  = 5
readNoteId "Sol" = 7
readNoteId "La"  = 9
readNoteId "Si"  = 11
readNoteId "C"  = 0
readNoteId "D"  = 2
readNoteId "E"  = 4
readNoteId "F"  = 5
readNoteId "G" = 7
readNoteId "A"  = 9
readNoteId "B"  = 11
readAlt "b" = Bemol
readAlt ""  = Naturel
readAlt "#" = Diese

readNote :: String -> Note
readNote noteS = let alteration = if last noteS == '#' || last noteS == 'b' then [last noteS] else ""
                 in Note (readNoteId $ take (length noteS - length alteration) noteS) (readAlt alteration)

type Intervalle = Int
fondamentale    = 0
secondeMineure  = 1
secondeMajeure  = 2
tierceMineure   = 3
tierceMajeure   = 4
quarte          = 5
quinteDim       = 6
quinte          = 7
quinteAug       = 8
sixte           = 9
septiemeMineure = 10
septiemeMajeure = 11

majeur      = [fondamentale, tierceMajeure, quinte]
mineur      = [fondamentale, tierceMineure, quinte]
septiemeDom = [fondamentale, tierceMajeure, quinte, septiemeMineure]
mineur7     = [fondamentale, tierceMineure, quinte, septiemeMineure]
majeur7     = [fondamentale, tierceMajeure, quinte, septiemeMajeure]

demiTon = 1
ton = 2
gammeMajeure :: [Int]
gammeMajeure = [0, ton, ton, demiTon, ton, ton, ton, demiTon]

-- Logique

valeur :: Note -> Int
valeur (Note blanche alt)
    | alt == Bemol = blanche - 1
    | alt == Naturel = blanche
    | alt == Diese = blanche + 1

cumul :: (Num a) => [a] -> [a]
cumul = cumul' 0 where cumul' _ [] = []
                       cumul' s (x:xs) = (x+s):(cumul' (s+x) xs)

construireGamme :: Note -> [Intervalle] -> [Note]
construireGamme (Note blancheFond altFond) typeGamme = let notes = map readNote ["Do", "Re", "Mi", "Fa", "Sol", "La", "Si"]
                                                           base = let (ls, rs) = break (\note -> getBlanche note == blancheFond) notes in rs ++ ls
                                                           cumulGamme = cumul typeGamme
                                                       in zipWith alterer base cumulGamme
                              where alterer (Note n _) intervalle = head [Note n alt
                                                                         | alt <- [Bemol, Naturel, Diese]
                                                                         , valeur (Note n alt) `mod` 12 == (valeur (Note blancheFond altFond) + intervalle) `mod` 12]

decaler :: Note -> Intervalle -> Note
decaler (Note n alt) intervalle = let arriveeId = (n + (valeurAlt alt) + intervalle) `mod` 12
                                  in if isBlancheId arriveeId
                                     then Note arriveeId Naturel
                                     else if alt == Bemol then Note (arriveeId+1) Bemol else Note (arriveeId-1) Diese
                                  where isBlancheId n = n == 0 || n == 2 || n == 4 || n == 5 || n == 7 || n == 9 || n == 11
                                        valeurAlt Diese = 1
                                        valeurAlt Naturel = 0
                                        valeurAlt Bemol = -1

{--
decaler :: Note -> Intervalle -> Note
decaler (Note n) intervalle = Note ((n+intervalle) `mod` 12)
--}

construireAccord :: Note -> [Intervalle] -> [Note]
construireAccord fondamentale intervalles = map (decaler fondamentale) intervalles

renverser :: Int -> [Note] -> [Note]
renverser n notes = reverse $ ((reverse $ take nb notes) ++ (take (length notes - nb) $ reverse notes)) where
                nb = n `mod` length notes

accord :: String -> [Note]
accord accordS = let tailleNote = if length accordS > 1 && (accordS !! 1 == '#' || accordS !! 1 == 'b') then 2 else 1
                     accordType = getAccordType $ drop tailleNote accordS
                 in  construireAccord (readNote $ take tailleNote accordS) accordType
                      where getAccordType ""   = majeur
                            getAccordType "m"  = mineur
                            getAccordType "-"  = mineur
                            getAccordType "7"  = septiemeDom
                            getAccordType "m7" = mineur7
                            getAccordType "-7" = mineur7
                            getAccordType "M7" = majeur7
                            getAccordType "maj7" = majeur7
      
-- Tests unitaires

testAccordMajeur  = ("Accord majeur           ", intercalate " " $ map show $ construireAccord (readNote "La") majeur, "La Do# Mi")
testAccordMineur  = ("Accord mineur           ", intercalate " " $ map show $ construireAccord (readNote "Do") mineur, "Do Mib Sol")
testAccord7dom    = ("Accord 7e dom           ", intercalate " " $ map show $ construireAccord (readNote "Sol") septiemeDom, "Sol Si Re Fa")
testAccordMineur7 = ("Accord mineur 7e        ", intercalate " " $ map show $ construireAccord (readNote "Mi") mineur7, "Mi Sol Si Re")
testAccordMajeur7D= ("Accord majeur 7 (diese) ", intercalate " " $ map show $ construireAccord (readNote "Do#") majeur7, "Do# Fa Sol# Do")
testAccordMajeur7b= ("Accord majeur 7 (bemol) ", intercalate " " $ map show $ construireAccord (readNote "Reb") majeur7, "Reb Fa Lab Do")
testRenversement  = ("Renversement            ", intercalate " " $ map show $ renverser 2 $ construireAccord (readNote "Do#") majeur7, "Sol# Do Do# Fa")
testparseAccordM  = ("Parsing d'accord majeur ", intercalate " " $ map show $ accord "C", "Do Mi Sol")
testparseAccordm  = ("Parsing d'accord mineur ", intercalate " " $ map show $ accord "Abm", "Lab Si Mib")
testparseAccord7  = ("Parsing d'accord 7e     ", intercalate " " $ map show $ accord "G#7", "Sol# Do Re# Fa#")
testparseAccordm7 = ("Parsing d'accord m7     ", intercalate " " $ map show $ accord "G#m7", "Sol# Si Re# Fa#")
testparseAccordM7 = ("Parsing d'accord maj7   ", intercalate " " $ map show $ accord "G#maj7", "Sol# Do Re# Sol")
testReadShowNote  = ("Lire/Afficher note      ", intercalate " " $ map show $ [readNote "Mi", readNote "Fa#", readNote "Solb"], "Mi Fa# Solb")
testGammeMajeure  = ("Gamme majeure           ", intercalate " " $ map show $ construireGamme (readNote "Re") gammeMajeure, "Re Mi Fa# Sol La Si Do#")


unitTest = let
              unitTestsAux = unlines $ map (\(nom, test, resultat) -> nom ++ ": " ++ (if test == resultat then "OK" else "FAILED")) [
                 testAccordMajeur
                ,testAccordMineur 
                ,testAccord7dom 
                ,testAccordMineur7
                ,testAccordMajeur7D
                ,testAccordMajeur7b
                ,testRenversement
                ,testparseAccordM
                ,testparseAccordm
                ,testparseAccord7
                ,testparseAccordm7
                ,testparseAccordM7
                ,testGammeMajeure
                ]
           in  putStrLn unitTestsAux

#! /usr/bin/python3

# Usage : ./cemantix_solver.py maison
# Then the program will play until it finds the correct word.
# The bin files used to load the model are downloadable from fauconnier.github.io/#data


import requests 
import sys 
from gensim.models import KeyedVectors

class Guess:
    def __init__(self, word, score):
        self.word = word
        self.score = score

class Solver:
    url = 'https://cemantix.herokuapp.com/score'
    try_list = list()
    # model = KeyedVectors.load_word2vec_format("frWiki_no_lem_no_postag_no_phrase_1000_cbow_cut100.bin", binary=True, unicode_errors="ignore")
    model = KeyedVectors.load_word2vec_format("./cémantix_files/frWac_no_postag_phrase_500_cbow_cut10.bin", binary=True, unicode_errors="ignore")
    # model = KeyedVectors.load_word2vec_format("./cémantix_files/frWac_non_lem_no_postag_no_phrase_200_cbow_cut0.bin", binary=True, unicode_errors="ignore")
    max_tries = 5000
    nb_similarities = 30
    top = list()

    def __init__(self):
        self.guesses = list()
        self.nb_tries = 0

    def display_summary(self):
        self.guesses =  sorted(self.guesses, key=lambda g: g.score)
        print()
        print("sorted guesses :")
        print()

        for g in self.guesses:
            print(g.word + ": " + str(g.score))

        for i in range(10):
            self.top.insert(0, self.guesses.pop())

        print()
        print("top 10 guesses :")
        for item in self.top:
            print(item.word + ": " + str(item.score))

    def new_guess(self, word):
        if self.nb_tries < self.max_tries:
            r = self.try_word(word)
            if self.is_valid(r):
                # print()
                # print("Guessing " + word)
                # print("results : " + str(r))
                self.nb_tries += 1
                score = r.get('score')
                percentile = r.get('percentile')
                print(word + " : " + str(score))
                if percentile == 1000:
                    self.display_summary()
                    print()
                    print("victoire, le mot était : " + word)
                    print("trouvé en " + str(self.nb_tries) + " tentatives")
                    # print("taille de guesses : " + str(len(self.guesses)))

                    exit(0)
                else :
                    if any(g.word == word for g in self.guesses):
                        return
                    else:
                        self.guesses.append(Guess(word, score))
                        ms = self.model.most_similar(word, topn=self.nb_similarities)
                        size = len(self.try_list)
                        for s in ms:
                            if any(s[0] == g.word for g in self.guesses):
                                continue
                            if any(s[0] == item[0] for item in self.try_list):
                                continue
                            # print(f"ref word : {word}   similar word :{s[0]}     ref word score : {score}")
                            item_score = (score * 10000) + s[1]
                            self.try_list.insert(size - 1, (s[0], item_score))
                        self.try_list = sorted(self.try_list, key=lambda res: res[1]) 
        else:
            self.display_summary()
            exit(0)

    def solve(self, starter_word):
        self.new_guess(starter_word)
        while self.try_list:
            self.new_guess(self.try_list.pop()[0])



    def try_word(self, word):
        payload = {
                'word': word
                }
        return requests.post(self.url, data=payload).json()

    def is_valid(self, res):
        return not "error" in res.keys()

s = Solver()
s.solve(sys.argv[1])
exit(0)

(import (owl io))
(import (owl list))
(import (owl list-extra))
(import (owl sort))

(define file->strings
  (λ (path)
     (map (λ (l) (if (eq? l '())
		     ""
		     (list->string l)))
	  (split (λ (x) (eq? 10 x)) (file->list path)))))

(define elves (sort > (map sum (split (λ (x) (eq? #f x))
			       (map string->integer (file->strings "in"))))))

(define p1 (car elves))
(define p2 (sum (take elves 3)))

(print p1)
(print p2)

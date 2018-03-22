
(defstruct rect
  (m_position '(0 0)) ;;(x y)
  (m_size     '(0 0)))

(defmethod draw ((rect rect))
  (gl:rect
   (car (rect-m_position rect))
   (cadr (rect-m_position rect))
   (+ (car (rect-m_position rect)) (car (rect-m_size rect)))
   (+ (cadr (rect-m_position rect)) (cadr (rect-m_size rect)))))

;; ;;当たり判定(point)
;; (defmethod intersect ((arg list))
;;   (if (and (>= (car arg) (car (rect-m_position *rect1*)))
;;            (< (car arg)
;;               (+ (car (rect-m_position *rect1*)) (car (rect-m_size *rect1*))))
;;            (>= (cadr arg) (cadr (rect-m_position *rect1*)))
;;            (< (cadr arg)
;;               (+ (cadr (rect-m_position *rect1*)) (cadr (rect-m_size *rect1*)))))
;;       t
;;       nil))

;; (defmethod intersect ((arg rect))
;;   (if (and (>= (+ (car (rect-m_position *rect1*)) (car (rect-m_size *rect1*)))
;;                (car (rect-m_position arg)))
;;            (< (car (rect-m_position *rect1*))
;;               (+ (car (rect-m_position arg)) (car (rect-m_size arg))))
;;            (>= (+ (cadr (rect-m_position *rect1*)) (cadr (rect-m_size *rect1*)))
;;                (cadr (rect-m_position arg)))
;;            (< (cadr (rect-m_position *rect1*))
;;               (+ (cadr (rect-m_position arg)) (cadr (rect-m_size arg)))))
;;       t
;;       nil))

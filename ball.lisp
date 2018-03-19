
(defstruct ball
  (m_radius 0)
  (m_lastposition '(0 0))
  (m_position '(0 0))
  (m_speed '(0 0)))

(defmethod update ((arg ball))
  (setf (ball-m_lastposition arg) (ball-m_position arg))
  (setf (ball-m_position arg)
        (mapcar #'+ (ball-m_speed arg) (ball-m_position arg)))
  )

(defmethod draw ((ball ball))
  (gl:push-matrix)
  (gl:translate (car (ball-m_position ball)) (cadr (ball-m_position ball)) 0)
  (gl:scale (ball-m_radius ball) (ball-m_radius ball) 0)
  (glut:solid-sphere 1 16 16)
  (gl:pop-matrix))

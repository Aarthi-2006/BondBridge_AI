# backend/services/ai_service.py

# ==========================================
# AI SERVICE
# ==========================================

def generate_ai_report(
    attendance_percentage,
    average_marks,
    homework_completion,
    strengths=None,
    improvement_areas=None
):
    """
    Generate AI-based student progress report.

    Gemini integration will be added in Module 1 - Step 5.
    """

    # ------------------------------------------
    # Prepare student performance data
    # ------------------------------------------

    student_data = {
        "attendance_percentage": attendance_percentage,
        "average_marks": average_marks,
        "homework_completion": homework_completion,
        "strengths": strengths,
        "improvement_areas": improvement_areas
    }

    # ------------------------------------------
    # AI generation will be connected later
    # ------------------------------------------

    return {
        "success": False,
        "message": "AI service is prepared. Gemini integration is not configured yet.",
        "data": student_data
    }
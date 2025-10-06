# API Response Structure Update

## Changes Made

The chatbot API response structure has been updated to provide more detailed information and better confidence scoring.

### Old Response Structure
```json
{
  "top_results": [
    {
      "answer": "...",
      "content": "..."
    }
  ]
}
```

### New Response Structure
```json
{
  "success": true,
  "results": [
    {
      "question": "How can I challenge thinking traps?",
      "answer": "What you tell yourself about a situation...",
      "score": 0.2382,
      "category": "General"
    }
  ],
  "message": "The results have low confidence. Consider rephrasing...",
  "query": "string",
  "total_results": 3
}
```

## Files Updated

### 1. `lib/services/api_service.dart`
- **Added Model Classes**:
  - `FaqResult`: Represents individual FAQ result with question, answer, score, and category
  - `FaqQueryResponse`: Represents the complete API response with metadata
  
- **Updated `queryFaq()` method**:
  - Changed return type from `Future<List<dynamic>>` to `Future<FaqQueryResponse>`
  - Now properly parses the new response structure with `results` field instead of `top_results`
  - Handles all metadata fields: success, message, query, total_results

### 2. `lib/screens/chat_screen.dart`
- **Enhanced Message Display**:
  - Shows question associated with each answer
  - Displays confidence scores as percentages
  - Shows category for each result
  - Displays warning message for low-confidence results
  - Shows result count (e.g., "Showing 3 of 10 results")
  
- **Better Response Formatting**:
  ```
  ⚠️ The results have low confidence. Consider rephrasing your question for better matches.

  I found some helpful information for you:

  **Q: How can I challenge thinking traps?**
  What you tell yourself about a situation affects how you feel...
  _Category: General | Confidence: 23.8%_
  ```

### 3. `lib/screens/api_test_screen.dart`
- **Detailed Test Output**:
  - Shows success status
  - Displays the query that was sent
  - Shows total number of results
  - Displays API message (including confidence warnings)
  - Lists each result with score and category

## Benefits

1. **Better User Feedback**: Users now see confidence scores and can understand when results may not be highly relevant
2. **Improved Context**: Questions are shown alongside answers for better understanding
3. **Category Organization**: Results are tagged with categories for easier navigation
4. **Low Confidence Warnings**: Users are notified when results have low confidence scores
5. **Type Safety**: Model classes provide compile-time type checking and better IDE support

## Testing

### Visual Comparison

**Before:**
```
I found some helpful information for you:

• What you tell yourself about a situation affects how you feel and what you do...

• MSP stands for Medical Services Plan...

• It can be difficult to find the things that will help you...
```

**After:**
```
⚠️ The results have low confidence. Consider rephrasing your question for better matches.

I found some helpful information for you:

**Q: How can I challenge thinking traps?**
What you tell yourself about a situation affects how you feel and what you do...
_Category: General | Confidence: 23.8%_

**Q: What is MSP?**
MSP stands for Medical Services Plan...
_Category: General | Confidence: 22.2%_

**Q: What do I do if the support doesn't help?**
It can be difficult to find the things that will help you...
_Category: General | Confidence: 21.5%_

_Showing 3 of 3 results_
```

### Test Steps

To test the updated implementation:

1. **Run API Test Screen**:
   - Navigate to the API test screen
   - Verify that the query test shows the new detailed output
   - Check that confidence scores and categories are displayed

2. **Test Chat Interface**:
   - Send a query in the chat screen
   - Verify that responses show:
     - Questions with answers
     - Confidence percentages
     - Categories
     - Low confidence warnings (if applicable)
     - Result counts

3. **Test Edge Cases**:
   - Try queries that may return low confidence results
   - Verify error handling still works
   - Check that the "no results" message displays correctly

## API Endpoint

The app connects to: `https://sepokonayuma-mental-health-faq.hf.space/faq`

**Note**: First request may take 30-60 seconds due to Hugging Face Spaces cold start.

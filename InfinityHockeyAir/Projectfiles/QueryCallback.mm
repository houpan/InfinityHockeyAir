
class QueryCallback : public b2QueryCallback
{
public:
    QueryCallback(const b2Vec2& point)
    {
        m_point = point;
        m_object = nil;
    }
    
    bool ReportFixture(b2Fixture* fixture)
    {
        if (fixture->IsSensor()) return true; //ignore sensors
        
        bool inside = fixture->TestPoint(m_point);
        if (inside)
        {
            // We are done, terminate the query.
            m_object = fixture->GetBody();
            return false;
        }
        
        // Continue the query.
        return true;
    }
    
    b2Vec2  m_point;
    b2Body* m_object;

};



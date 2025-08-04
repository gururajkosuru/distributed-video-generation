import { useState, useEffect } from 'react';
import './console.css';

interface Job {
  job_id: string;
  status: string;
  prompt: string;
  output?: string;
  error?: string;
}

interface LogEntry {
  timestamp: string;
  message: string;
  type: 'info' | 'success' | 'error';
}

function App() {
  const [prompt, setPrompt] = useState('');
  const [jobs, setJobs] = useState<Job[]>([]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [logs, setLogs] = useState<LogEntry[]>([]);
  const [selectedVideo, setSelectedVideo] = useState<string | null>(null);
  const [accountId] = useState('guru'); // Could be made configurable

  const addLog = (message: string, type: 'info' | 'success' | 'error' = 'info') => {
    const timestamp = new Date().toLocaleTimeString();
    setLogs(prev => [...prev.slice(-19), { timestamp, message, type }]); // Keep last 20 logs
  };

  // Load jobs on component mount
  useEffect(() => {
    loadJobs();
    const interval = setInterval(loadJobs, 3000); // Auto-refresh every 3 seconds
    return () => clearInterval(interval);
  }, []);

  const loadJobs = async () => {
    try {
      const res = await fetch(`/jobs/${accountId}`);
      if (res.ok) {
        const data = await res.json();
        setJobs(data.jobs || []);
      }
    } catch (error) {
      addLog('Failed to load jobs', 'error');
    }
  };

  const submitJob = async () => {
    if (!prompt.trim()) {
      addLog('Please enter a prompt', 'error');
      return;
    }

    setIsSubmitting(true);
    try {
      const res = await fetch('/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt: prompt.trim(), account_id: accountId }),
      });

      if (res.ok) {
        const data = await res.json();
        addLog(`Job submitted: ${data.job_id}`, 'success');
        setPrompt('');
        loadJobs(); // Refresh job list
      } else {
        const errorData = await res.text();
        addLog(`Failed to submit job: ${res.status} - ${errorData}`, 'error');
      }
    } catch (error) {
      addLog('Network error', 'error');
    } finally {
      setIsSubmitting(false);
    }
  };

  const refreshJobs = () => {
    addLog('Refreshing jobs...', 'info');
    loadJobs();
  };

  const playVideo = (job: Job) => {
    if (job.status === 'COMPLETED') {
      const videoUrl = `/download/${job.job_id}`;
      setSelectedVideo(videoUrl);
      addLog(`Playing video: ${job.job_id}`, 'info');
      console.log('Setting video URL:', videoUrl);
    } else {
      addLog(`Cannot play video: Job status is ${job.status}`, 'error');
    }
  };

  const getStatusClass = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending': return 'status-pending';
      case 'running': return 'status-running';
      case 'completed': return 'status-completed';
      case 'failed': return 'status-failed';
      default: return '';
    }
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !isSubmitting) {
      submitJob();
    }
  };

  return (
    <div className="console-container">
      <div className="console-header">
        <div className="console-title">MOCHI VIDEO GENERATION TERMINAL</div>
        <div className="console-subtitle">Distributed AI Video Generation System v1.0</div>
      </div>

      {/* Job Submission */}
      <div className="console-section">
        <div className="section-header">► Start New Job</div>
        <div className="section-content">
          <input
            className="console-input"
            type="text"
            placeholder="Enter video generation prompt..."
            value={prompt}
            onChange={(e) => setPrompt(e.target.value)}
            onKeyPress={handleKeyPress}
            disabled={isSubmitting}
          />
          <button
            className="console-button"
            onClick={submitJob}
            disabled={isSubmitting || !prompt.trim()}
          >
            {isSubmitting ? <span className="loading">SUBMITTING</span> : 'SUBMIT JOB'}
          </button>
        </div>
      </div>

      {/* Job List */}
      <div className="console-section">
        <div className="section-header">
          ► Job Queue ({jobs.length})
          <button className="console-button" onClick={refreshJobs} style={{float: 'right', padding: '5px 10px', fontSize: '12px'}}>
            REFRESH
          </button>
        </div>
        <div className="section-content">
          <div className="job-list">
            {jobs.length === 0 ? (
              <div style={{color: '#888', textAlign: 'center', padding: '20px'}}>
                No jobs found. Submit your first video generation job above.
              </div>
            ) : (
              jobs.map((job) => (
                <div key={job.job_id} className="job-item">
                  <div className="job-header">
                    <span className="job-id">ID: {job.job_id.substring(0, 8)}...</span>
                    <span className={`job-status ${getStatusClass(job.status)}`}>
                      {job.status}
                    </span>
                  </div>
                  <div className="job-prompt">"{job.prompt}"</div>
                  <div className="job-actions">
                    {job.status === 'COMPLETED' && (
                      <>
                        <button
                          className="console-button"
                          onClick={(e) => {
                            e.preventDefault();
                            console.log('Play button clicked for job:', job.job_id);
                            playVideo(job);
                          }}
                          style={{padding: '5px 10px', fontSize: '12px'}}
                        >
                          PLAY VIDEO
                        </button>
                        <a
                          href={`/download/${job.job_id}`}
                          download
                          className="console-button"
                          style={{padding: '5px 10px', fontSize: '12px', textDecoration: 'none', display: 'inline-block'}}
                        >
                          DOWNLOAD
                        </a>
                      </>
                    )}
                    {job.status === 'FAILED' && job.error && (
                      <div style={{color: '#ff0000', fontSize: '12px', marginTop: '5px'}}>
                        Error: {job.error}
                      </div>
                    )}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Video Player */}
      {selectedVideo && (
        <div className="console-section">
          <div className="section-header">► Video Player</div>
          <div className="section-content">
            <div className="video-player">
              <video
                className="console-video"
                controls
                autoPlay
                key={selectedVideo}
                onLoadStart={() => addLog('Loading video...', 'info')}
                onCanPlay={() => addLog('Video ready to play', 'success')}
                onError={(e) => {
                  console.error('Video error:', e);
                  addLog('Error loading video', 'error');
                }}
              >
                <source src={selectedVideo} type="video/mp4" />
                Your browser does not support the video tag.
              </video>
            </div>
            <div style={{marginTop: '10px', color: '#888', fontSize: '12px'}}>
              Video URL: {selectedVideo}
            </div>
            <button
              className="console-button"
              onClick={() => setSelectedVideo(null)}
              style={{marginTop: '10px'}}
            >
              CLOSE PLAYER
            </button>
          </div>
        </div>
      )}

      {/* Console Log */}
      <div className="console-section">
        <div className="section-header">► System Log</div>
        <div className="section-content">
          <div className="console-log">
            {logs.length === 0 ? (
              <div className="log-entry">
                <span className="log-timestamp">[{new Date().toLocaleTimeString()}]</span>
                <span className="log-info">System initialized. Ready for video generation.</span>
              </div>
            ) : (
              logs.map((log, index) => (
                <div key={index} className="log-entry">
                  <span className="log-timestamp">[{log.timestamp}]</span>
                  <span className={`log-${log.type}`}>{log.message}</span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;

